require_relative 'process-runner'
require_relative 'dcp/dcp-logger'
require_relative 'dcp/dcp-crawler'
require 'fileutils'
require 'optparse'
#
# Execute this script with -h to see the list of available command line options.
#
class ExecuteDcpChecks

  def initialize(test_dir, process_runner)
    @test_dir = test_dir
    @process_runner = process_runner
    @logger = DcpLogger.log
  end

  #
  # Execute specified test type with the given command line arguments.
  #
  def execute_checks(args = [])
    test_configuration = parse_command_line(args)
    if test_configuration[:docker]
      run_tests_in_docker(test_configuration)
    else
      run_tests_from_command_line(test_configuration)
    end
  end

  private

  #
  # Parses the command line supplied to the run-test.rb wrapper script.
  #
  def parse_command_line(args)
    puts args
    test_configuration = {}

    option_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: run-checks.rb [options]'
      opts.separator 'Specific options:'

      opts.on('--base-url RHD_BASE_URL', String, 'Run the checks against a specified dcp e.g https://dcp2.jboss.org/v2/rest/search/developer_materials?') do |host|
        test_configuration[:base_url] = host
      end

      opts.on('--use-docker', 'Run the specified test type using Docker') do
        test_configuration[:docker] = true
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        Kernel.exit(1)
      end
    end

    begin
      option_parser.parse!(args)
    rescue OptionParser::InvalidOption => e
      puts e
      option_parser.parse(%w(-h))
    end
    build_test_execution_cmd(test_configuration)
    test_configuration
  end

  #
  # Runs the specified test type within Docker by executing
  # a number of Docker commands in sequence.
  #
  def run_tests_in_docker(test_configuration)
    compose_project_name = 'rhd_dcp_checking'
    compose_environment_directory = "#{@test_dir}/environments"

    @logger.info('Launching dcp-ckecker testing environment...')
    @process_runner.execute!("cd #{compose_environment_directory} && docker-compose -p #{compose_project_name} build")

    @logger.info('Test environment up and running. Running dcp checks...')
    @process_runner.execute!("cd #{compose_environment_directory} && docker-compose -p #{compose_project_name} run --rm --no-deps rhd_dcp_checks #{test_configuration[:run_tests_command]}")
    @logger.info('Completed run of dcp checks')
  end

  def run_tests_from_command_line(test_configuration)
    @logger.info('Running dcp checks from the command line...')
    @process_runner.execute!(test_configuration[:run_tests_command])
    @logger.info('Completed command line run of dcp checks.')
  end

  #
  # Builds dcp broken link checking test command based on given parameters
  #
  def build_test_execution_cmd(test_configuration)
    test_configuration[:run_tests_command] = "ruby dcp/dcp-crawler.rb #{test_configuration[:base_url]}"
  end

end

if $PROGRAM_NAME == __FILE__
  base_dir = File.dirname(__FILE__)
  begin
    run_tests = ExecuteDcpChecks.new(base_dir, ProcessRunner.new)
    run_tests.execute_checks(ARGV)
    Kernel.exit(0)
  rescue
    Kernel.exit(1)
  end
end
