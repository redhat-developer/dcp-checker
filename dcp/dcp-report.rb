require 'slim'
require 'ostruct'
require 'fileutils'
require 'rounding'

require_relative 'dcp-logger'

class Report

  HTML_REPORT = File.expand_path('report.html.slim', File.dirname(__FILE__))

  def initialize(context)
    @context = context
    @logger = DcpLogger.log
  end

  def render
    errors = []
    result = Hash.new { |h, k| h[k] = [] }
    @context[:errors].each do |error|
      unless error.nil?
        result["#{error[:content_type]}".to_sym] << error
        errors << error
      end
    end

    pass_rate = "#{(errors.size).percent_of(@context[:total]).round_to(1)}%"
    File.open('dcp-report.html', 'w') do |file|
      file.write(Slim::Template.new(HTML_REPORT).render(OpenStruct.new(total: @context[:total],
                                                                       errors: errors,
                                                                       context: result,
                                                                       pass_rate: pass_rate)))
    end
  end
end

class Numeric
  def percent_of(n)
    100 - self.to_f / n.to_f * 100.0
  end
end
