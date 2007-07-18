require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#status" do
  before(:each) do
    @twitter = client_context
    @message = 'This is my unique message'
    @uris = Twitter::Client.class_eval("@@STATUS_URIS")
    @options = {:id => 666666}
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, '{}')
    @connection = mas_net_http(@response)
    @float = 43.3434
    @status = Twitter::Status.new(:id => 2349343)
    @source = Twitter::Client.class_eval("@@defaults[:source]")
  end

  it "should return nil if nil is passed as value argument for :get case" do
    status = @twitter.status(:get, nil)
    status.should be_nil
  end
  
  it "should not call @twitter#http_connect when passing nil for value argument in :get case" do
    @twitter.should_not_receive(:http_connect)
    @twitter.status(:get, nil)
  end
  
  it "should create expected HTTP GET request for :get case" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:get], @options).and_return(@request)
    @twitter.status(:get, @options[:id])
  end
  
  it "should invoke @twitter#create_http_get_request with given parameters equivalent to {:id => value.to_i} for :get case" do
    # Float case
    @twitter.should_receive(:create_http_get_request).with(@uris[:get], {:id => @float.to_i}).and_return(@request)
    @twitter.status(:get, @float)

    # Twitter::Status object case
    @twitter.should_receive(:create_http_get_request).with(@uris[:get], {:id => @status.to_i}).and_return(@request)    
    @twitter.status(:get, @status)
  end
  
  it "should return nil if nil is passed as value argument for :post case" do
    status = @twitter.status(:post, nil)
    status.should be_nil
  end
  
  it "should not call @twitter#http_connect when passing nil for value argument in :post case" do
    @twitter.should_not_receive(:http_connect)
    @twitter.status(:post, nil)
  end
  
  it "should create expected HTTP POST request for :post case" do
    @twitter.should_receive(:create_http_post_request).with(@uris[:post]).and_return(@request)
    @connection.should_receive(:request).with(@request, {:status => @message, :source => @source}.to_http_str).and_return(@response)
    @twitter.status(:post, @message)
  end
  
  it "should return nil if nil is passed as value argument for :delete case" do
    status = @twitter.status(:delete, nil)
    status.should be_nil
  end
  
  it "should not call @twitter#http_connect when passing nil for value argument in :delete case" do
    @twitter.should_not_receive(:http_connect)
    @twitter.status(:delete, nil)
  end
  
  it "should create expected HTTP DELETE request for :delete case" do
    @twitter.should_receive(:create_http_delete_request).with(@uris[:delete], @options).and_return(@request)
    @twitter.status(:delete, @options[:id])
  end

  it "should invoke @twitter#create_http_get_request with given parameters equivalent to {:id => value.to_i} for :delete case" do
    # Float case
    @twitter.should_receive(:create_http_delete_request).with(@uris[:delete], {:id => @float.to_i}).and_return(@request)
    @twitter.status(:delete, @float)

    # Twitter::Status object case
    @twitter.should_receive(:create_http_delete_request).with(@uris[:delete], {:id => @status.to_i}).and_return(@request)
    @twitter.status(:delete, @status)
  end
  
  it "should raise an ArgumentError when given an invalid status action" do
    lambda {
      @twitter.status(:crap, nil)
    }.should raise_error(ArgumentError)
  end
    
  after(:each) do
    nilize(@twitter)
  end
end
