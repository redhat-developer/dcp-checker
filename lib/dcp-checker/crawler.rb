require 'json'
require 'ostruct'
require 'uri'
require 'parallel'
require 'dcp-checker/logger'
require 'dcp-checker/restclient-wrapper'

module DcpChecker
# This class will query the dcp per content type, and return an array of 'sys_url_view' urls, it will then check for broken links
# using the dcp-engine class.
  class Crawler

    def initialize(config)
      @max_retrys = 3
      @config = config.validate
      @logger = DcpChecker.logger
      @cached = {}
      @robots_txt_cache = {}
    end

    def content
      content = {}
      @config[:content].each do |type|
        content.store(type, collect(type))
      end
      content
    end

    def analyze
      errors = []
      total = 0
      content.each do |content_type, urls|
        @logger.info("Checking #{urls.length} links".yellow)
        @processed = 0
        total += urls.size
        Parallel.each(urls, in_threads: (Parallel.processor_count * 2)) do |url|
          is_url = is_url?(url)
          next unless is_url
          if @cached.has_key?(url.chomp('/'))
            @logger.info("Loaded #{url} from cache".green)
            res = @cached["#{url.chomp('/')}"][:response]
          else
            unless @last_checked.nil?
              url_base = get_base(url)
              if @last_checked.include?(url_base)
                timestamp = ::Time.now - @last_checked_timestamp
                respect_robots_txt(url_base)
                if timestamp < @delay
                  @logger.info("Respecting the website robots.txt Crawl-delay, waiting for #{@delay - timestamp} second(s)")
                  sleep(@delay - timestamp)
                end
              end
            end
            browser = DcpChecker::RestClientWrapper.new(@config)
            res = browser.process(url)
            @cached["#{url.chomp('/')}"] = {response: res}
            @last_checked = get_base(url)
            @last_checked_timestamp = ::Time.now
          end

          if res == SocketError
            resp_code = 503
            message = 'Site can’t be reached'
          elsif res == RestClient::Exceptions::Timeout || res == RestClient::Exceptions::OpenTimeout
            resp_code = 404
            message = 'Not Found'
          else
            (res.is_a? RestClient::Response) ? response = res : response = res.response
            resp_code = response.code.to_i
            message = res.message.gsub!(/\d+ /, '') if resp_code > 400 || resp_code == 0
          end

          @processed += 1

          if resp_code > 400 || resp_code == 0
            errors.push(OpenStruct.new(content_type: content_type, url: url, code: resp_code, message: message))
          end

          @logger.info("Processed #{@processed} of #{urls.size}".yellow)
        end
      end

      if errors.size > 0
        @logger.warn("DANGER: #{errors.size} errors found for #{total} links".red)
        OpenStruct.new(total: total, errors: errors)
      else
        @logger.info("SUCCESS: No errors found for #{total} pages".green)
        errors.size
      end
    end


    private

    def get(url)
      begin
        response = RestClient::Request.execute(method: :get, url: url, max_redirects: 6, timeout: 30, verify_ssl: false)
        JSON.parse(response.body)
      rescue RestClient::ExceptionWithResponse => err
        err.response
      end
    end

    def query(from, type)
      get("#{@config[:base_url]}/rest/search/developer_materials?/tags_or_logic=true&filter_out_excluded=true&from=#{from}&size100=true&type=#{type}")
    end

    def collect(type)
      urls = []
      i = 0
      size = total_size(0, type)
      while i <= size
        urls << sys_urls(i, type)
        i += 100
      end
      urls.flatten!
      urls.uniq
    end

    def total_size(from, type)
      query = query(from, type)
      total = query['hits']['total']
      total.to_int.floor_to(100)
    end

    def sys_urls(from, type)
      sys_urls = []
      query = query(from, type)
      query['hits']['hits'].each do |link|
        sys_urls << link['fields']['sys_url_view']
      end
      sys_urls
    end

    def respect_robots_txt(uri)
      @delay = 0
      begin
        unless @robots_txt_cache.has_key?(uri)
          robots = URI.join(uri.to_s, "/robots.txt").open
          @robots_txt_cache["#{uri}"] = {response: robots}
        end
        @robots_txt_cache["#{uri}"][:response].each do |line|
          next if line =~ /^\s*(#.*|$)/
          arr = line.split(":")
          key = arr.shift
          value = arr.join(":").strip
          value.strip!
          @delay = value.to_i if key.downcase == 'crawl-delay'
        end
      rescue => error
        unless error.message.include?('404')
          @logger.warn("#{error} when accessing robots.txt for #{uri}") if @config.verbose
        end
      end
    end

    def get_base(url)
      uri = URI.parse(url)
      "#{uri.scheme}://#{uri.host}"
    end

    def is_url?(url)
      uri = URI.parse(url) rescue false
      uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
    end
  end
end
