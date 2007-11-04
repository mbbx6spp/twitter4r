require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Twitter::Client, "#featured(:users)" do
  before(:each) do
    @twitter = client_context
    @uris = Twitter::Client.class_eval("@@FEATURED_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success)
    @connection = mas_net_http(@response)
    Net::HTTP.stub!(:new).and_return(@connection)
    @users = [
      Twitter::User.new(:screen_name => 'twitter4r'),
      Twitter::User.new(:screen_name => 'dictionary'),      
    ]
    Twitter::User.stub!(:unmarshal).and_return(@users)
  end
  
  it "should create expected HTTP GET request" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:users]).and_return(@request)
    @twitter.featured(:users)
  end
  
  it "should bless Twitter::User models returned" do
    @twitter.should_receive(:bless_models).with(@users).and_return(@users)
    @twitter.featured(:users)
  end
  
  after(:each) do
    nilize(@twitter, @uris, @request, @response, @connection)
  end
end

describe Twitter::User, ".featured" do
  before(:each) do
    @twitter = client_context
  end
  
  it "should delegate #featured(:users) message to given client context" do
    @twitter.should_receive(:featured).with(:users).and_return([])
    Twitter::User.featured(@twitter)
  end
  
  after(:each) do
    nilize(@twitter)
  end
end
