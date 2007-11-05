require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#authenticate?" do
  before(:each) do
    @uri = '/account/verify_credentials.json'
    @request = mas_net_http_get(:basic_auth => nil)
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
    @response = mas_net_http_response(:success)
    @error_response = mas_net_http_response(404, "Resource Not Found")
    @connection = mas_net_http(@response)
    Net::HTTP.stub!(:new).and_return(@connection)
    @login = "applestillsucks"
    @password = "linuxstillrocks"
  end
  
  it "creates expected HTTP GET request" do
    @twitter.should_receive(:create_http_get_request).with(@uri).and_return(@request)
    @twitter.authenticate?(@login, @password)
  end
  
  it "should return true if HTTP response is 20X" do
    @twitter.authenticate?(@login, @password).should be(true)
  end
  
  it "should return false if HTTP response is not 20X" do
    Net::HTTP.stub!(:new).and_return(mas_net_http(@error_response))
    @twitter.authenticate?(@login, @password).should be(false)
  end
  
  after(:each) do
    nilize(@uri, @request, @twitter, @default_header, @response, @error_response, @connection, @login, @password)
  end
end
