require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#favorites" do
  before(:each) do
    @uri = '/favorites.json'
    @request = mas_net_http_get(:basic_auth => nil)
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    @options = { :page => 4 }
    Net::HTTP.stub!(:new).and_return(@connection)
    @favorites = []
    Twitter::Status.stub!(:unmarshal).and_return(@favorites)
  end
  
  it "should create expected HTTP GET request when not giving options" do
    @twitter.should_receive(:create_http_get_request).with(@uri).and_return(@request)
    @twitter.favorites
  end
  
  it "should create expected HTTP GET request when giving :page options" do
    @twitter.should_receive(:create_http_get_request).with("#{@uri}?#{@options.to_http_str}").and_return(@request)
    @twitter.favorites(@options)
  end
  
  it "should raise Twitter::RESTError when 401 HTTP response received without giving options" do
    @connection = mas_net_http(mas_net_http_response(:not_authorized))
    lambda {
      @twitter.favorites
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 401 HTTP response received when giving page options" do
    @connection = mas_net_http(mas_net_http_response(:not_authorized))
    lambda {
      @twitter.favorites(@options)
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 403 HTTP response received without giving options" do
    @connection = mas_net_http(mas_net_http_response(:forbidden))
    lambda {
      @twitter.favorites
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 403 HTTP response received when giving page options" do
    @connection = mas_net_http(mas_net_http_response(:forbidden))
    lambda {
      @twitter.favorites(@options)
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 500 HTTP response received without giving options" do
    @connection = mas_net_http(mas_net_http_response(:server_error))
    lambda {
      @twitter.favorites
    }.should raise_error(Twitter::RESTError)
  end
  
  it "should raise Twitter::RESTError when 500 HTTP response received when giving page options" do
    @connection = mas_net_http(mas_net_http_response(:server_error))
    lambda {
      @twitter.favorites(@options)
    }.should raise_error(Twitter::RESTError)
  end
  
  after(:each) do
    nilize(@uri, @request, @twitter, @default_header, @response, @error_response, @connection)
  end
end

module FavoriteSpecMixin
  def init
    @base_uri = '/favourings'
    @request = mas_net_http_get(:basic_auth => nil)
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    Net::HTTP.stub!(:new).and_return(@connection)
    @id = 234923423
    @status = mas_twitter_status(:id => @id, :to_i => @id)
    Twitter::Status.stub!(:unmarshal).and_return(@status)
  end
  
  def create_uri(method, id)
    "#{@base_uri}/#{method.to_s}/#{id.to_i.to_s}.json"
  end
  
  def connection=(connection)
    @connection = connection
  end
  
  def finalize
    nilize(@uri, @request, @twitter, @default_header, @response, @error_response, @connection)
  end
end

describe "Twitter::Client#favorite error handling", :shared => true do
  it "should raise a Twitter::RESTError exception when a 401 HTTP response is received" do
    connection = mas_net_http(mas_net_http_response(:not_authorized))
    lambda {
      execute_method
    }.should raise_error(Twitter::RESTError)
  end  

  it "should raise a Twitter::RESTError exception when a 403 HTTP response is received" do
    connection = mas_net_http(mas_net_http_response(:forbidden))
    lambda {
      execute_method
    }.should raise_error(Twitter::RESTError)
  end  

  it "should raise a Twitter::RESTError exception when a 404 HTTP response is received" do
    connection = mas_net_http(mas_net_http_response(:file_not_found))
    lambda {
      execute_method
    }.should raise_error(Twitter::RESTError)
  end  

  it "should raise a Twitter::RESTError exception when a 500 HTTP response is received" do
    connection = mas_net_http(mas_net_http_response(:server_error))
    lambda {
      execute_method
    }.should raise_error(Twitter::RESTError)
  end  
end

describe Twitter::Client, "#favorite(:add, status)" do
  include FavoriteSpecMixin
  it_should_behave_like "Twitter::Client#favorite error handling"
  
  before(:each) do
    init
  end
  
  def execute_method
    @twitter.favorite(:add, @id)
  end
  
  it "should create expected POST request for :add action supplying integer id of status" do
    @twitter.should_receive(:create_http_post_request).with(create_uri(:create, @id)).and_return(@request)
    @twitter.favorite(:add, @id)
  end
  
  it "should create expected POST request for :add action supplying status object" do
    @twitter.should_receive(:create_http_post_request).with(create_uri(:create, @id)).and_return(@request)
    @twitter.favorite(:add, @status)
  end
  
  after(:each) do
    finalize
  end
end

describe Twitter::Client, "#favorite(:remove, status)" do
  include FavoriteSpecMixin
  it_should_behave_like "Twitter::Client#favorite error handling"

  before(:each) do
    init
  end
  
  def execute_method
    @twitter.favorite(:remove, @id)
  end
  
  it "should create expected DELETE request for :remove action supplying integer id of status" do
    @twitter.should_receive(:create_http_delete_request).with(create_uri(:destroy, @id)).and_return(@request)
    @twitter.favorite(:remove, @id)
  end
  
  it "should create expected DELETE request for :remove action supplying status object" do
    @twitter.should_receive(:create_http_delete_request).with(create_uri(:destroy, @id)).and_return(@request)
    @twitter.favorite(:remove, @status)
  end
  
  after(:each) do
    finalize
  end
end
