require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#graph(:friends...)" do
  before(:each) do
    @twitter = client_context
    @id = 1234567
    @screen_name = 'dummylogin'
    @friend = Twitter::User.new(:id => @id, :screen_name => @screen_name)
    @uris = Twitter::Client.class_eval("@@GRAPH_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success)
    @response.stub!(:body).and_return("[1, 2, 3, 4, 5, 6]")
    @connection = mas_net_http(@response)
    Net::HTTP.stub!(:new).and_return(@connection)
    Twitter::User.stub!(:unmarshal).and_return(@friend)
  end
  
  def create_uri(action)
    "#{@uris[action]}.json"
  end
  
  it "should create expected HTTP GET request for :friends case using integer user ID" do
  	# the integer user ID scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:friends), :id => @id).and_return(@request)
    @twitter.graph(:friends, @id)
  end
  
  it "should create expected HTTP GET request for :friends case using screen name" do
    # the screen name scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:friends), :id => @screen_name).and_return(@request)
    @twitter.graph(:friends, @screen_name)
  end

  it "should create expected HTTP GET request for :friends case using Twitter::User object" do
    # the Twitter::User object scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:friends), :id => @friend.to_i).and_return(@request)
    @twitter.graph(:friends, @friend)
  end
  
  it "should create expected HTTP GET request for :followers case using integer user ID" do
    # the integer user ID scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:followers), :id => @id).and_return(@request)
    @twitter.graph(:followers, @id)
  end

  it "should create expected HTTP GET request for :followers case using screen name" do
    # the screen name scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:followers), :id => @screen_name).and_return(@request)
    @twitter.graph(:followers, @screen_name)
  end

  it "should create expected HTTP GET request for :followers case using Twitter::User object" do
    # the Twitter::User object scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:followers), :id => @friend.to_i).and_return(@request)
    @twitter.graph(:followers, @friend)
  end
  
  it "should raise ArgumentError if action given is not valid" do
    lambda {
      @twitter.graph(:crap, @friend)
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@twitter, @id, @uris, @request, @response, @connection)
  end
end
