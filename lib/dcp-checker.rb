require 'dcp-checker/version'
require 'dcp-checker/report'
require 'dcp-checker/config'
require 'dcp-checker/error'
require 'dcp-checker/time'
require 'dcp-checker/logger'
require 'dcp-checker/crawler'

module DcpChecker
  module_function

  def self.execute(options = {})
    config = if options[:config_file]
               DcpChecker::Config.read(options[:config_file], options)
             else
               DcpChecker::Config.read(File.join(File.dirname(__dir__), '.', 'config/dcp-config.yml'), options)
             end
    result = DcpChecker::Crawler.new(config).analyze
    DcpChecker::Report.new(result).render
  end
end
