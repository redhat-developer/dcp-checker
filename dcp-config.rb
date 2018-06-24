require 'yaml'
require 'erb'
require_relative 'dcp-logger'

class DcpConfig

  def initialize
    @config = []
    @file = 'config/dcp-config.yml'
    @logger = DcpLogger.log
  end

  def open
    fail('Config file not found') unless File.exist?(@file)
    @config = YAML.load(ERB.new(File.read(@file)).result)
  rescue ArgumentError => e
    @logger.warn("Could not parse YAML: #{e.message}")
  end

end
