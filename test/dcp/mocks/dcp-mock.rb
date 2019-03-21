class DcpMock
  include WebMock::API

  def initialize(config)
    @config = config
  end

  def map(content_type, body, from = 0)
    stub_request(:get, "#{@config[:base_url]}/rest/search/developer_materials?/tags_or_logic=true&filter_out_excluded=true&from=#{from}&size100=true&type=#{content_type}").
        with(
            headers: {
                'Accept' => '*/*'
            }).to_return(status: 200, body: body, headers: {})
  end

  def stub_url(url, status)
    stub_request(:get, url).
        with(headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip, deflate',
            'Host'=>'developers.redhat.com',
            'User-Agent'=>'rest-client/2.0.2 (darwin16.6.0 x86_64) ruby/2.4.1p111'
        }).
        to_return(status: status, body: "", headers: {})
  end

  def mock_robots_txt
    stub_request(:get, %r{\A\.*?\/robots.text}).
        with(headers: {
            'Accept' => '*/*'
        }).
        to_return(status: 200, body: robots, headers: {})
  end

  def robots
    'User-agent: *'
  end

end
