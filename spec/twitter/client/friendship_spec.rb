require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#friend" do
  before(:each) do
    @twitter = client_context
    @id = 1234567
    @screen_name = 'dummylogin'
    @friend = Twitter::User.new(:id => @id, :screen_name => @screen_name)
    @uris = Twitter::Client.class_eval("@@FRIENDSHIP_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    Net::HTTP.stub!(:new).and_return(@connection)
    Twitter::User.stub!(:unmarshal).and_return(@friend)
  end
  
  def create_uri(action, id)
  	"#{@uris[action]}/#{id}.json"
  end
  
  it "should create expected HTTP GET request for :add case using integer user ID" do
  	# the integer user ID scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:add, @id)).and_return(@request)
    @twitter.friend(:add, @id)
  end
  
  it "should create expected HTTP GET request for :add case using screen name" do
  	# the screen name scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:add, @screen_name)).and_return(@request)
    @twitter.friend(:add, @screen_name)
  end

	it "should create expected HTTP GET request for :add case using Twitter::User object" do
  	# the Twitter::User object scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:add, @friend.to_i)).and_return(@request)
    @twitter.friend(:add, @friend)
  end
  
  it "should create expected HTTP GET request for :remove case using integer user ID" do
  	# the integer user ID scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:remove, @id)).and_return(@request)
    @twitter.friend(:remove, @id)
  end

	it "should create expected HTTP GET request for :remove case using screen name" do
  	# the screen name scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:remove, @screen_name)).and_return(@request)
    @twitter.friend(:remove, @screen_name)
  end

  it "should create expected HTTP GET request for :remove case using Twitter::User object" do
  	# the Twitter::User object scenario...
    @twitter.should_receive(:create_http_get_request).with(create_uri(:remove, @friend.to_i)).and_return(@request)
    @twitter.friend(:remove, @friend)
  end
  
  it "should bless user model returned for :add case" do
    @twitter.should_receive(:bless_model).with(@friend)
    @twitter.friend(:add, @friend)
  end
  
  it "should bless user model returned for :remove case" do
    @twitter.should_receive(:bless_model).with(@friend)
    @twitter.friend(:remove, @friend)
  end
  
  it "should raise ArgumentError if action given is not valid" do
    lambda {
      @twitter.friend(:crap, @friend)
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@twitter, @id, @uris, @request, @response, @connection)
  end
end
