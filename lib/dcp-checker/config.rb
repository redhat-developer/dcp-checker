require 'yaml'
require 'erb'
require 'ostruct'

module DcpChecker
  #
  # This class reads specified config file in order to  , or merges user specified custom
  # config settings.
  #
  class Config < OpenStruct

    def self.read(file, args = {})
      raise("Config file '#{file}' not found") unless File.exist?(file)
      config = YAML.load(ERB.new(File.read(file)).result)
      Config.new(config.merge(args))
    end

    def initialize(config)
      super(config)
    end

    def validate
      raise 'Please specify dcp base_url' if base_url.nil?
      raise 'Please specify dcp content type(s)' if content.nil?
      self
    end
  end
end
