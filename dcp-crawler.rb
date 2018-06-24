require 'json'
require 'ostruct'
require 'pathname'
require 'typhoeus'
require 'rounding'
require 'uri'
require_relative 'dcp-logger'
require_relative 'dcp-config'
require_relative 'dcp-error'
require_relative 'dcp-report'
require_relative 'typhoeus_wrapper'

# This class will query the dcp per content type, and return an array of 'sys_url_view' urls, it will then check for broken links
# using the dcp-engine class.
class DcpCrawler
  attr_accessor :errors

  def initialize(base_url)
    @base_url = base_url
    @max_retrys = 3
    @config = DcpConfig.new.open
    @logger = DcpLogger.log
  end

  def content
    content = {}
    @config['content'].each do |type|
      content.store(type, collect(type))
    end
    content
  end

  def analyze
    errors = []
    total = 0
    content.each do |content_type, urls|
      @logger.info("Checking #{urls.size} links for #{content_type}".blue)
      @processed = 0
      total += urls.size
      blc = TyphoeusWrapper.new
      blc.process_all(urls, @max_retrys) do |response|
        url = response.request.base_url
        resp_code = response.code.to_i

        if resp_code > 400 || resp_code == 0
          response = response
          if response.status_message.nil?
            message = response.return_message
          else
            message = response.status_message
          end
          errors.push(OpenStruct.new(content_type: content_type, url: url, code: resp_code, message: message))
        end

        @processed += 1
        @logger.info("Processed #{@processed} of #{urls.size} for #{content_type}".yellow)
      end
    end
    if errors.size > 0
      @logger.warn("DANGER: #{errors.size} errors found for #{total} links".red)
    else
      @logger.info("SUCCESS: No errors found for #{total} pages".green)
    end
    context = OpenStruct.new(total: total, errors: errors)
    Report.new(context).render
  end

  private

  def get(url)
    response = Typhoeus.get(url, headers: { 'User-Agent' => 'Red Hat Developers Testing' })
    JSON.parse(response.body)
  end

  def query(from, type)
    get("#{@base_url}/tags_or_logic=true&filter_out_excluded=true&from=#{from}&size100=true&type=#{type}")
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

end
