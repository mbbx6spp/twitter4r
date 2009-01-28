require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#account_info" do
  before(:each) do
    @uri = Twitter::Client.class_eval("@@ACCOUNT_URIS[:rate_limit_status]")
    @request = mas_net_http_get(:basic_auth => nil)
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    @response.stub!(:body).and_return("{}")
    Net::HTTP.stub!(:new).and_return(@connection)
    @rate_limit_status = mock(Twitter::RateLimitStatus)
    @twitter.stub!(:bless_models).and_return({})
  end

  it "should create expected HTTP GET request" do
    @twitter.should_receive(:create_http_get_request).with(@uri).and_return(@request)
    @twitter.account_info
  end

  it "should raise Twitter::RESTError when 500 HTTP response received when giving page options" do
    @connection = mas_net_http(mas_net_http_response(:server_error))
    lambda {
      @twitter.account_info
    }.should raise_error(Twitter::RESTError)
  end
end
