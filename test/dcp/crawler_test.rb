require_relative '../../test/test_helper'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'json'

require_relative 'mocks/dcp-mock'

class TestDcpChecker < Minitest::Test

  describe DcpChecker::Crawler do

    before do
      options = {}
      @jbossdeveloper_example = File.read("#{__dir__}/mocks/jbossdeveloper_example.json")
      @jbossdeveloper_quickstart = File.read("#{__dir__}/mocks/jbossdeveloper_quickstart.json")
      options[:config_file] = {content: ['jbossdeveloper_quickstart', 'jbossdeveloper_example'],
                               base_url: 'https://dcp2.jboss.org/v2/rest/search/developer_materials?'}
      @config = DcpChecker::Config.new(options[:config_file])
      %w[jbossdeveloper_quickstart jbossdeveloper_example].each do |content_type|
        DcpMock.new(@config).map(content_type, instance_variable_get("@#{content_type}"))
      end
    end

    it 'should return an array of content types' do
      content_types = []
      DcpChecker::Crawler.new(@config).content.each do |content_type, _|
        content_types << content_type
      end
      assert_equal(2, content_types.size)
    end

    it 'should not check duplicate links' do
      DcpChecker::Crawler.new(@config).content.each do |_, urls|
        assert_equal(1, urls.size)
      end
    end

    it 'should iterate through results if containing more than 100' do
      options = {}
      options[:config_file] = {content: ['jbossdeveloper_vimeo'],
                               base_url: 'https://dcp2.jboss.org/v2/rest/search/developer_materials?'}
      config = DcpChecker::Config.new(options[:config_file])
      display_results = [0, 100, 200, 300]
      display_results.each do |from|
        DcpMock.new(config).map('jbossdeveloper_vimeo', File.read("#{__dir__}/mocks/jbossdeveloper_vimeo_from_#{from}.json"), from)
      end

      DcpChecker::Crawler.new(config).content.each do |_, urls|
        assert_equal(347, urls.size)
      end
    end

    it 'should capture broken links' do
      DcpMock.new(@config).stub_url('https://developers.redhat.com///quickstarts/eap/kitchensink-jsp', 404)
      DcpMock.new(@config).stub_url('https://developers.redhat.com//ticket-monster/businesslogic', 200)
      links = DcpChecker::Crawler.new(@config).analyze
      assert_equal(1, links[:errors].size)
    end

    it 'should not capture errors when all links are passing' do
      DcpMock.new(@config).stub_url('https://developers.redhat.com///quickstarts/eap/kitchensink-jsp', 200)
      DcpMock.new(@config).stub_url('https://developers.redhat.com//ticket-monster/businesslogic', 200)
      links = DcpChecker::Crawler.new(@config).analyze
      assert_equal(0, links)
    end
  end
end
