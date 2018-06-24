require 'logger'
require 'colorize'

#
# Sets up the default logging style to be used across all functions
#
class DcpLogger

  #
  # @return A default configured logger instance
  #
  def self.log
    log = Logger.new(STDOUT)
    log.formatter = proc do |severity, datetime, _, msg|
      date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
      "[#{date_format}] #{severity} - #{msg.gsub("\n", '')}\n"
    end
    log
  end
end
