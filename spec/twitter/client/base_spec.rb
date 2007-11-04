require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "Twitter::Client" do
  before(:each) do
    @init_hash = { :login => 'user', :password => 'pass' }
  end

  it ".new should accept login and password as initializer hash keys and set the values to instance values" do
    client = nil
    lambda do
      client = Twitter::Client.new(@init_hash)
    end.should_not raise_error
    client.send(:login).should eql(@init_hash[:login])
    client.send(:password).should eql(@init_hash[:password])
  end  
end

describe Twitter::Client, "#http_header" do
  before(:each) do
    @user_agent = 'myapp'
    @application_name = @user_agent
    @application_version = '1.2.3'
    @application_url = 'http://myapp.url'
    Twitter::Client.configure do |conf|
      conf.user_agent = @user_agent
      conf.application_name = @application_name
      conf.application_version = @application_version
      conf.application_url = @application_url
    end
    @expected_headers = {
      'Accept' => 'text/x-json',
      'X-Twitter-Client' => @application_name,
      'X-Twitter-Client-Version' => @application_version,
      'X-Twitter-Client-URL' => @application_url,
      'User-Agent' => "Twitter4R v#{Twitter::Version.to_version} [#{@user_agent}]",
    }
    @twitter = client_context
    # reset @@http_header class variable in Twitter::Client class
    Twitter::Client.class_eval("@@http_header = nil")
  end
  
  it "should always return expected HTTP headers" do
    headers = @twitter.send(:http_header)
    headers.should === @expected_headers
  end
  
  it "should cache HTTP headers Hash in class variable after first invocation" do
    cache = Twitter::Client.class_eval("@@http_header")
    cache.should be_nil
    @twitter.send(:http_header)
    cache = Twitter::Client.class_eval("@@http_header")
    cache.should_not be_nil
    cache.should === @expected_headers
  end
  
  after(:each) do
    nilize(@user_agent, @application_name, @application_version, @application_url, @twitter, @expected_headers)
  end
end

describe Twitter::Client, "#create_http_get_request" do
  before(:each) do
  	@uri = '/some/path'
  	@expected_get_request = mock(Net::HTTP::Get)
    @twitter = client_context
  	@default_header = @twitter.send(:http_header)
  end
  
  it "should create new Net::HTTP::Get object with expected initialization arguments" do
  	Net::HTTP::Get.should_receive(:new).with(@uri, @default_header).and_return(@expected_get_request)
		@twitter.send(:create_http_get_request, @uri)
  end
  
  after(:each) do
    nilize(@twitter, @uri, @expected_get_request, @default_header)
  end
end

describe Twitter::Client, "#create_http_post_request" do
  before(:each) do
  	@uri = '/some/path'
  	@expected_post_request = mock(Net::HTTP::Post)
  	@twitter = client_context
  	@default_header = @twitter.send(:http_header)
  end
    
  it "should create new Net::HTTP::Post object with expected initialization arguments" do
  	Net::HTTP::Post.should_receive(:new).with(@uri, @default_header).and_return(@expected_post_request)
    @twitter.send(:create_http_post_request, @uri)
  end
  
  after(:each) do
    nilize(@twitter, @uri, @expected_post_request, @default_header)    
  end
end

describe Twitter::Client, "#create_http_delete_request" do
  before(:each) do
    @uri = '/a/stupid/path/that/is/not/restful/since/twitter.com/cannot/do/consistent/restful/apis'
    @expected_delete_request = mock(Net::HTTP::Delete)
    @twitter = client_context
    @default_header = @twitter.send(:http_header)
  end
  
  it "should create new Net::HTTP::Delete object with expected initialization arguments" do
    Net::HTTP::Delete.should_receive(:new).with(@uri, @default_header).and_return(@expected_delete_request)
    @twitter.send(:create_http_delete_request, @uri)
  end
  
  after(:each) do
    nilize(@twitter, @uri, @expected_delete_request, @default_header)
  end
end

describe Twitter::Client, "#http_connect" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @good_response = mas_net_http_response(:success)
    @bad_response = mas_net_http_response(:server_error)
    @http_stubs = {:is_a? => true}
    @block = Proc.new do |conn|
      conn.is_a?(Net::HTTP).should be(true)
      @has_yielded = true
      @request
    end
    @twitter = client_context
    @has_yielded = false
  end
  
  def generate_bad_response
    @http = mas_net_http(@bad_response, @http_stubs)
    Net::HTTP.stub!(:new).and_return(@http)
  end
  
  def generate_good_response
    @http = mas_net_http(@good_response, @http_stubs)
    Net::HTTP.stub!(:new).and_return(@http)
  end
  
  it "should yield HTTP connection when response is good" do
    generate_good_response
    @http.should_receive(:is_a?).with(Net::HTTP).and_return(true)
    lambda do
      @twitter.send(:http_connect, &@block)
    end.should_not raise_error
    @has_yielded.should be(true)
  end
  
  it "should yield HTTP connection when response is bad" do
    generate_bad_response
    @http.should_receive(:is_a?).with(Net::HTTP).and_return(true)
    lambda {
      @twitter.send(:http_connect, &@block)
    }.should raise_error(Twitter::RESTError)
    @has_yielded.should be(true)
  end
  
  after(:each) do
    nilize(@good_response, @bad_response, @http)
  end
end

describe Twitter::Client, "#bless_model" do
  before(:each) do
    @twitter = client_context
    @model = Twitter::User.new
  end
  
  it "should recieve #client= message on given model to self" do
  	@model.should_receive(:client=).with(@twitter)
    model = @twitter.send(:bless_model, @model)
  end
  
  it "should set client attribute on given model to self" do
    model = @twitter.send(:bless_model, @model)
    model.client.should eql(@twitter)
  end

  # if model is nil, it doesn't not necessarily signify an exceptional case for this method's usage.
  it "should return nil when receiving nil and not raise any exceptions" do
    model = @twitter.send(:bless_model, nil)
    model.should be_nil
  end
  
  # needed to alert developer that the model needs to respond to #client= messages appropriately.
  it "should raise an error if passing in a non-nil object that doesn't not respond to the :client= message" do
    lambda {
      @twitter.send(:bless_model, Object.new)      
    }.should raise_error(NoMethodError)
  end
  
  after(:each) do
    nilize(@twitter)
  end
end

describe Twitter::Client, "#bless_models" do
  before(:each) do
    @twitter = client_context
    @models = [
    	Twitter::Status.new(:text => 'message #1'),
    	Twitter::Status.new(:text => 'message #2'),
    ]
  end

  it "should set client attributes for each model in given Array to self" do
    models = @twitter.send(:bless_models, @models)
    models.each {|model| model.client.should eql(@twitter) }
  end
  
  it "should set client attribute for singular model given to self" do
    model = @twitter.send(:bless_models, @models[0])
    model.client.should eql(@twitter)
  end
  
  it "should delegate to bless_model for singular model case" do
    model = @models[0]
    @twitter.should_receive(:bless_model).with(model).and_return(model)
    @twitter.send(:bless_models, model)
  end
  
  it "should return nil when receiving nil and not raise any exceptions" do
    lambda {
      value = @twitter.send(:bless_models, nil)
      value.should be_nil
    }.should_not raise_error
  end
  
  after(:each) do
    nilize(@twitter, @models)
  end
end
