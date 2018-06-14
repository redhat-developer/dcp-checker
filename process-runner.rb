require 'open3'
require_relative 'dcp/dcp-logger'

#
# <p> Class that wraps the execution of command line. Will raise an Error if the requested command does not return
# with a zero status.
# </p>
class ProcessRunner

  class ProcessFailedError < StandardError

  end

  def initialize
    @logger = DcpLogger.log
  end

  def determine_process_status(cmd, execution_result)
    raise(ProcessFailedError, "Execution of command '#{cmd}' failed.") unless execution_result
  end

  #
  # Execute the command, returning the result of the Kernel.system call
  #
  def execute(cmd)
    @logger.info("Executing command '#{cmd}'...")
    Kernel.system(cmd)
  end

  #
  # <p>Execute the given command specified by cmd.</p>
  #
  # @throws - ProcessFailedError if the command exits with a non-zero status
  #
  def execute!(cmd)
    execution_result = execute(cmd)
    determine_process_status(cmd, execution_result)
  end

  #
  # Executes the given command, returning true if the command succeeded (i.e. returned a zero exit code), or false
  # otherwise
  #
  def execute?(cmd)
    execution_result = execute(cmd)
    !execution_result.nil? && execution_result
  end


  private :determine_process_status, :execute

end