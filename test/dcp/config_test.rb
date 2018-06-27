require 'test_helper'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'dcp-checker/config'

class TestDcpChecker < Minitest::Test
  describe DcpChecker::Config do
    it 'should raise an error if it cannot read config file' do
      config = '/no/way/this/exists.yml'
      args = {}
      exception = assert_raises(RuntimeError) {
        DcpChecker::Config.read(config, args)
      }
      assert_equal("Config file '#{config}' not found", exception.message)
    end

    it 'should create a merged Hash of user specified commandline options and default config options' do
      options = {}
      args = {}
      options[:config_file] = "#{__dir__}/config/dcp-config.yml"
      expected_hash = { base_url: 'https://dcp2.jboss.org/v2/rest/search/developer_materials?', content: ['jbossdeveloper_quickstart', 'jbossdeveloper_example', 'jbossdeveloper_vimeo'] }
      actual_hash = DcpChecker::Config.read(options[:config_file], args)
      assert_equal(expected_hash.to_s, actual_hash.to_h.to_s)
    end

    it 'should raise an error when base_url is not specified' do
      options = {}
      options[:config_file] = options[:config_file] = { 'content' => ['jbossdeveloper_quickstart'] }
      exception = assert_raises(RuntimeError) {
        config = DcpChecker::Config.new(options[:config_file])
        config.validate
      }
      assert_equal('Please specify dcp base_url', exception.message)
    end

    it 'should allow user to override default base_url' do
      options = {}
      args = {}
      options[:config_file] = "#{__dir__}/config/dcp-config.yml"
      args[:base_url] = 'https://foo.bar.com/'
      expected_hash = { base_url: 'https://foo.bar.com/', content: ['jbossdeveloper_quickstart', 'jbossdeveloper_example', 'jbossdeveloper_vimeo'] }
      actual_hash = DcpChecker::Config.read(options[:config_file], args)
      assert_equal(expected_hash.to_s, actual_hash.to_h.to_s)
    end

    it 'should raise an error when content types are not specified' do
      options = {}
      options[:config_file] = { 'base_url' => 'http://test.com' }

      exception = assert_raises(RuntimeError) {
        config = DcpChecker::Config.new(options[:config_file])
        config.validate
      }
      assert_equal('Please specify dcp content type(s)', exception.message)
    end
  end
end
