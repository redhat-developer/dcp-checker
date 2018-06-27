#!/usr/bin/env ruby
require 'dcp-checker'
require 'optparse'
Encoding.default_external = 'UTF-8'

options = {}

OptionParser.new do |opts|
    opts.banner = 'Usage: dcp-checker [options]'
    opts.separator 'Specific options:'

    opts.on('--base-url URL', 'specify the URL of the site root') do |opt|
      options[:base_url] = opt
    end
    opts.on('--config CONFIG', 'Specify custom config file location') do |opt|
      options[:config] = opt
    end
  end.parse!

require 'date'
require 'dcp-checker/time'
require 'dcp-checker/logger'
require 'colorize'
require 'openssl'

start = DateTime.now
DcpChecker.logger.info("Started at #{start}")
DcpChecker.execute(options)
puts("Total time: #{(DateTime.now.to_time - start.to_time).duration}")
