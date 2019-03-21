require 'rest-client'

module DcpChecker
  class RestClientWrapper
    attr_reader :count

    def initialize(config)
      @config = config
      @logger = DcpChecker.logger
    end

    def process(url)
      retries = 0
      begin
        RestClient::Request.execute(method: :get, url: url, max_redirects: 3, timeout: 30, verify_ssl: false)
      rescue RestClient::ExceptionWithResponse, SocketError => result
        return result.class if result.class == SocketError
        if retries < 3
          retries += 1
          @logger.info("Loading #{url} (attempt #{retries} of 3)".yellow)
          retry
        else
          @logger.info("Loading #{url} failed".red)
          (result.is_a?(RestClient::Exceptions::Timeout) || result.is_a?(RestClient::Exceptions::OpenTimeout)) ?
              response = result.class :
              response = result
          return response
        end
      end
    end

    def get(url)
      begin
        RestClient::Request.execute(method: :get, url: url, max_redirects: 3, timeout: 30, verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => err
        err.response
      end
    end
  end
end
