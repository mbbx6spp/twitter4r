require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#user(id, :followers)" do
  before(:each) do
    @twitter = client_context    
    @id = 395783
  end
  
  it "should raise ArgumentError" do
    lambda {
      @twitter.user(@id, :followers)
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@twitter, @id)
  end
end

describe Twitter::Client, "#user(id, :info)" do
  before(:each) do
    @twitter = client_context
    @id = 395783
    @screen_name = 'boris_johnson_is_funny_as_hell'
    @user = Twitter::User.new(
    	:id => @id, 
    	:screen_name => @screen_name, 
    	:location => 'London'
    )
    @json = JSON.unparse(@user.to_hash)
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)
    @uris = Twitter::Client.class_eval("@@USER_URIS")
    @twitter.stub!(:create_http_get_request).and_return(@request)
    Twitter::User.stub!(:unmarshal).and_return(@user)
    Net::HTTP.stub!(:new).and_return(@connection)
  end
  
  it "should create expected HTTP GET request when giving numeric user id" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:info], {:id => @id}).and_return(@request)
    @twitter.user(@id)
  end
    
  it "should create expected HTTP GET request when giving screen name" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:info], {:id => @screen_name}).and_return(@request)
    @twitter.user(@screen_name)
  end
  
  it "should bless model returned when giving numeric user id" do
    @twitter.should_receive(:bless_model).with(@user).and_return(@user)
    @twitter.user(@id)
  end
  
  it "should bless model returned when giving screen name" do
    @twitter.should_receive(:bless_model).with(@user).and_return(@user)
    @twitter.user(@screen_name)
  end

  after(:each) do
    nilize(@request, @response, @connection, @twitter, @id, @screen_name, @user)
  end
end

# TODO: Add specs for new Twitter::Client#user(id, :friends) and 
# Twitter::Client#user(id, :followers) use cases.
describe Twitter::Client, "#user(id, :friends)" do
  before(:each) do
    @twitter = client_context
    @id = 395784
    @screen_name = 'cafe_paradiso'
    @user = Twitter::User.new(
      :id => @id,
      :screen_name => @screen_name,
      :location => 'Urbana, IL'
    )
    @json = JSON.unparse(@user.to_hash)
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)
    @uris = Twitter::Client.class_eval("@@USER_URIS")
    @twitter.stub!(:create_http_get_request).and_return(@request)
    Twitter::User.stub!(:unmarshal).and_return(@user)
    Net::HTTP.stub!(:new).and_return(@connection)
  end
  
  it "should create expected HTTP GET request when giving numeric user id" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:friends], {:id => @id}).and_return(@request)
    @twitter.user(@id, :friends)
  end
  
  it "should invoke #to_i on Twitter::User objecct given" do
    @user.should_receive(:to_i).and_return(@id)
    @twitter.user(@user, :friends)
  end
  
  it "should create expected HTTP GET request when giving Twitter::User object" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:friends], {:id => @user.to_i}).and_return(@request)
    @twitter.user(@user, :friends)
  end
  
  it "should create expected HTTP GET request when giving screen name" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:friends], {:id => @screen_name}).and_return(@request)
    @twitter.user(@screen_name, :friends)
  end
  
  it "should bless model returned when giving numeric id" do
    @twitter.should_receive(:bless_model).with(@user).and_return(@user)
    @twitter.user(@id, :friends)
  end
  
  it "should bless model returned when giving Twitter::User object" do
    @twitter.should_receive(:bless_model).with(@user).and_return(@user)
    @twitter.user(@user, :friends)    
  end
  
  it "should bless model returned when giving screen name" do
    @twitter.should_receive(:bless_model).with(@user).and_return(@user)
    @twitter.user(@screen_name, :friends)
  end
  
  after(:each) do
    nilize(@request, @response, @connection, @twitter, @id, @screen_name, @user)
  end
end

describe Twitter::Client, "#my(:info)" do
  before(:each) do
    @twitter = client_context
    @screen_name = @twitter.instance_eval("@login")
    @user = Twitter::User.new(
      :id => 2394393, 
      :screen_name => @screen_name,
      :location => 'Glamorous Urbana'
    )
    @json = JSON.unparse(@user.to_hash)
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)
    @uris = Twitter::Client.class_eval("@@USER_URIS")
    @twitter.stub!(:create_http_get_request).and_return(@request)
    Net::HTTP.stub!(:new).and_return(@connection)
    Twitter::User.stub!(:unmarshal).and_return(@user)
  end
  
  it "should create expected HTTP GET request" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:info], :id => @screen_name).and_return(@request)
    @twitter.my(:info)
  end
  
  it "should bless the model object returned" do
    @twitter.should_receive(:bless_models).with(@user).and_return(@user)
    @twitter.my(:info)
  end
  
  it "should return expected user object" do
    user = @twitter.my(:info)
    user.should eql(@user)
  end

  after(:each) do
    nilize(@request, @response, @connection, @twitter, @user, @screen_name)
  end
end

describe Twitter::Client, "#my(:friends)" do
  before(:each) do
    @twitter = client_context
    @screen_name = @twitter.instance_eval("@login")
    @friends = [
      Twitter::User.new(:screen_name => 'lucy_snowe'),
      Twitter::User.new(:screen_name => 'jane_eyre'),
      Twitter::User.new(:screen_name => 'tess_derbyfield'),
      Twitter::User.new(:screen_name => 'elizabeth_jane_newson'),
    ]
    @json = JSON.unparse(@friends.collect {|f| f.to_hash })
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)
    @uris = Twitter::Client.class_eval("@@USER_URIS")
    @twitter.stub!(:create_http_get_request).and_return(@request)
    Twitter::User.stub!(:unmarshal).and_return(@friends)
    Net::HTTP.stub!(:new).and_return(@connection)
  end
  
  it "should create expected HTTP GET request" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:friends], :id => @screen_name).and_return(@request)
    @twitter.my(:friends)
  end
  
  it "should bless models returned" do
    @twitter.should_receive(:bless_models).with(@friends).and_return(@friends)
    @twitter.my(:friends)
  end
  
  it "should return expected Array of friends" do
    friends = @twitter.my(:friends)
    friends.should eql(@friends)
  end
  
  after(:each) do
    nilize(@request, @response, @connection, @twitter, @friends, @screen_name)
  end
end

describe Twitter::Client, "#my(:invalid_action)" do
  before(:each) do
    @twitter = client_context
  end
  
  it "should raise ArgumentError for invalid user action" do
    lambda {
      @twitter.my(:crap)
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@twitter)
  end
end
