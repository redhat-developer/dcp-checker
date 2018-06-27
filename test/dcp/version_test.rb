require 'test_helper'
require 'minitest/autorun'
require 'mocha/mini_test'

class DcpCheckerTest < Minitest::Test
  describe DcpChecker do
    it 'should have a version number' do
      assert_equal('0.1.0', DcpChecker::VERSION)
    end
  end
end
