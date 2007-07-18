require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "Timeline API" do
  before(:each) do
    @client = client_context
    @uris = Twitter::Client.class_eval("@@TIMELINE_URIS")
    @user = Twitter::User.new(:screen_name => 'mylogin')
    @status = Twitter::Status.new(:id => 23343443, :text => 'I love Lucy!', :user => @user)
    @timeline = [@status]
    @json = JSON.unparse([@status.to_hash])
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)
    @params = {
      :public => {:since_id => 3249328},
			:friends => {:id => 'myfriend'},
			:user => {:id => 'auser'},
			:me => {},
    }
  end
  
  it "should respond to instance method #timeline_for" do
    @client.should respond_to(:timeline_for)
  end
  
  it "should call #http_get with expected parameters for :public case" do
    @client.should_receive(:http_connect).and_return(mas_net_http_response(:success, @json))
    @client.timeline_for(:public)
  end
  
  it "should yield to block for each status in timeline" do
    @client.should_receive(:http_connect).and_return(mas_net_http_response(:success, @json))
    Twitter::Status.should_receive(:unmarshal).and_return(@timeline)
    count = 0
    @client.timeline_for(:public) do |status|
      status.should eql(@status)
      count += 1
    end
    count.should eql(@timeline.size)
  end
  
  it "should generate expected HTTP GET request for generic :public case" do
    @client.should_receive(:create_http_get_request).with(@uris[:public], {}).and_return(@request)
    timeline = @client.timeline_for(:public)
    timeline.should eql(@timeline)
  end
  
  it "should generate expected HTTP GET request for :public case with expected parameters" do
    @client.should_receive(:create_http_get_request).with(@uris[:public], @params[:public]).and_return(@request)
    timeline = @client.timeline_for(:public, @params[:public])
    timeline.should eql(@timeline)
  end
  
  it "should generate expected HTTP GET request for generic :friends case" do
  	@client.should_receive(:create_http_get_request).with(@uris[:friends], {}).and_return(@request)
  	timeline = @client.timeline_for(:friends)
  	timeline.should eql(@timeline)
  end
  
  it "should generate expected HTTP GET request for :friends case with expected parameters" do
    @client.should_receive(:create_http_get_request).with(@uris[:friends], @params[:friends]).and_return(@request)
    timeline = @client.timeline_for(:friends, @params[:friends])
    timeline.should eql(@timeline)
  end
  
  it "should raise an ArgumentError if type given is not valid" do
    lambda {
      @client.timeline_for(:crap)
    }.should raise_error(ArgumentError)
    
    lambda { 
      @client.timeline_for(:crap, @params[:friends])
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@client)
  end
end
