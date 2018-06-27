require 'colorize'
require 'logger'

# global logger for dcp-checker.
module DcpChecker
  class << self
    attr_accessor :logger
  end
end

DcpChecker.logger = Logger.new(STDOUT)
