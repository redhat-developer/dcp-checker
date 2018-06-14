require 'typhoeus'
require_relative 'dcp-logger'

class TyphoeusWrapper

  def initialize
    # Typhoeus::Config.cache = DcP::Cache.new
    @hydra = Typhoeus::Hydra.new(maxconnects: (30), max_total_connections: (30), pipelining: false, max_concurrency: (30))
    Ethon::Curl.set_option(:max_host_connections, 5, @hydra.multi.handle, :multi)
    @logger = DcpLogger.log
    @count = 0
  end

  def process_all(urls, limit, opts = {}, &block)
    urls.each do |url|
      process(url, limit, opts, &block)
    end
    @hydra.run
  end

  def process(url, limit, opts = {}, &block)
    _process(url, limit, limit, opts, &block)
  end

  private

  def _process(url, limit, max, opts = {}, &block)
    req = Typhoeus::Request.new(url,
                                opts.merge(followlocation: true, timeout: 60,
                                           cookiefile: '_tmp/cookies', cookiejar: '_tmp/cookies',
                                           connecttimeout: 30, maxredirs: 5, ssl_verifypeer: false))
    req.on_complete do |resp|
      if retry?(resp)
        if resp.code == 0
          response = nil
          begin
            uri = URI.parse(url[0])
            http_response = Net::HTTP.get_response(uri)
            response = Typhoeus::Response.new(code: http_response.code, status_message: http_response.message, mock: true)
          rescue
            response = Typhoeus::Response.new(code: 410, status_message: 'Could not reach the resource', mock: true)
          end
          response.request = Typhoeus::Request.new(url, ssl_verifypeer: false)
          Typhoeus.stub(url).and_return(response)
          block.call(response, nil, nil)
          next
        end
        if limit > 1
          @logger.info("Loading #{url} via typhoeus (attempt #{max - limit + 2} of #{max})")
          _process(url, limit - 1, max, &Proc.new)
        else
          @logger.info("Loading #{url} via typhoeus failed")
          response = Typhoeus::Response.new(code: 0, status_message: "Server timed out after #{max} retries",
                                            mock: true)
          response.request = Typhoeus::Request.new(url, ssl_verifypeer: false)
          Typhoeus.stub(url).and_return(response)
          block.call(response, nil, nil)
        end
      else
        block.call(resp, nil, nil)
      end
    end
    @hydra.queue(req)
    # throttle to avoid akamai blocking checks
    sleep(0.5)
    @count += 1
  end

  def retry?(resp)
    resp.timed_out? || (resp.code == 0)
  end

end
