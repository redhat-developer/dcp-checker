$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dcp-checker'
require 'minitest/reporters'
require 'webmock/minitest'
reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
