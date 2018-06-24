require_relative 'dcp-logger'
require_relative 'dcp-crawler'
require_relative 'process-runner'
require 'fileutils'
require 'optparse'
#
# Execute this script with -h to see the list of available command line options.
#
class ExecuteDcpChecks

  def initialize(test_dir)
    @test_dir = test_dir
    @logger = DcpLogger.log
  end

  #
  # Execute specified test type with the given command line arguments.
  #
  def execute_checks(args = [])
    test_configuration = parse_command_line(args)
    start = DateTime.now
    @logger.info("Started at #{start}")
    if test_configuration[:docker]
      run_tests_in_docker(test_configuration)
    else
      run_tests_from_command_line(test_configuration)
    end
    @logger.info("Total time: #{(DateTime.now.to_time - start.to_time)}")
    Kernel.exit(0)
  end

  private

  #
  # Parses the command line supplied to the run-test.rb wrapper script.
  #
  def parse_command_line(args)
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
      option_parser.parse(%w(-h))
    end
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
    system("cd #{compose_environment_directory} && docker-compose -p #{compose_project_name} build")

    @logger.info('Test environment up and running. Running dcp checks...')
    system("cd #{compose_environment_directory} && docker-compose -p #{compose_project_name} run --rm --no-deps rhd_dcp_checks #{DcpCrawler.new(test_configuration[:base_url]).analyze}")
    @logger.info('Completed run of dcp checks')
  end

  def run_tests_from_command_line(test_configuration)
    @logger.info('Running dcp checks from the command line...')
    DcpCrawler.new(test_configuration[:base_url]).analyze
    @logger.info('Completed command line run of dcp checks.')
  end

end

if $PROGRAM_NAME == __FILE__
  base_dir = File.dirname(__FILE__)
  begin
    run_tests = ExecuteDcpChecks.new(base_dir)
    run_tests.execute_checks(ARGV)
    Kernel.exit(0)
  rescue
    Kernel.exit(1)
  end
end
