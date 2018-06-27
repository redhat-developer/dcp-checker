module DcpChecker
  class Error
    attr_reader :content_type, :url, :code, :message

    def initialize(opts = {})
      @content_type = opts[:content_type]
      @url = opts[:url]
      @code = opts[:code]
      @message = opts[:message]
    end

    def to_json(*args)
      content = {}
      instance_variables.each do |v|
        content[v.to_s[1..-1]] = instance_variable_get v
      end
      content.to_json
    end
  end
end
