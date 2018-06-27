class DcpMock
  include WebMock::API
  def initialize(config)
    @config = config
  end

  def map(content_type, body, from = 0)
    stub_request(:get, "#{@config[:base_url]}/tags_or_logic=true&filter_out_excluded=true&from=#{from}&size100=true&type=#{content_type}").
        with(headers: {
            'Expect' => '',
            'User-Agent' => 'Red Hat Developers Testing'
        }).to_return(status: 200, body: body, headers: {})
  end

  def stub_url(url, status)
    stub_request(:get, url).
        with(  headers: {
            'Expect'=>'',
            'User-Agent'=>'Red Hat Developers Testing'
        }).
        to_return(status: status, body: "", headers: {})
  end
end
