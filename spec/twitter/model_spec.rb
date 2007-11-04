require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module Test
  class Model
    include Twitter::ModelMixin
  end
end

describe Twitter::Status, "unmarshaling" do
  before(:each) do
    @json_hash = { "text" => "Thinking Zipcar is lame...",
                   "id" => 46672912,
                   "user" => {"name" => "Angie",
                              "description" => "TV junkie...",
                              "location" => "NoVA",
                              "profile_image_url" => "http:\/\/assets0.twitter.com\/system\/user\/profile_image\/5483072\/normal\/eye.jpg?1177462492",
                              "url" => nil,
                              "id" => 5483072,
                              "protected" => false,
                              "screen_name" => "ang_410"},
                   "created_at" => "Wed May 02 03:04:54 +0000 2007"}
    @user = Twitter::User.new @json_hash["user"]
    @status = Twitter::Status.new @json_hash
    @status.user = @user
  end
  
  it "should respond to unmarshal class method" do
    Twitter::Status.should respond_to(:unmarshal)
  end
  
  it "should return expected Twitter::Status object for singular case" do
    status = Twitter::Status.unmarshal(JSON.unparse(@json_hash))
    status.should_not be(nil)
    status.should eql(@status)
  end
  
  it "should return expected array of Twitter::Status objects for plural case" do
    statuses = Twitter::Status.unmarshal(JSON.unparse([@json_hash]))
    statuses.should_not be(nil)
    statuses.should have(1).entries
    statuses.first.should eql(@status)
  end
end

describe Twitter::User, "unmarshaling" do
  before(:each) do
    @json_hash = { "name" => "Lucy Snowe",
                   "description" => "School Mistress Entrepreneur",
                   "location" => "Villette",
                   "url" => "http://villetteschoolforgirls.com",
                   "id" => 859303,
                   "protected" => true,
                   "screen_name" => "LucyDominatrix", }
    @user = Twitter::User.new @json_hash
  end
  
  it "should respond to unmarshal class method" do
    Twitter::User.should respond_to(:unmarshal)
  end
  
  it "should return expected arry of Twitter::User objects for plural case" do
    users = Twitter::User.unmarshal(JSON.unparse([@json_hash]))
    users.should have(1).entries
    users.first.should eql(@user)
  end
  
  it "should return expected Twitter::User object for singular case" do
    user = Twitter::User.unmarshal(JSON.unparse(@json_hash))
    user.should_not be(nil)
    user.should eql(@user)
  end
end

describe "Twitter::ModelMixin#to_hash" do
	before(:all) do
    class Model
    	include Twitter::ModelMixin
    	@@ATTRIBUTES = [:id, :name, :value, :unused_attr]
    	attr_accessor *@@ATTRIBUTES
    	def self.attributes; @@ATTRIBUTES; end
    end
    
    class Hash
    	def eql?(other)
    		return false unless other # trivial nil case.
    		return false unless self.keys.eql?(other.keys)
    		self.each do |key,val|
    			return false unless self[key].eql?(other[key])
    		end
    		true
    	end
    end
	end

  before(:each) do
    @attributes = {:id => 14, :name => 'State', :value => 'Illinois'}
    @model = Model.new(@attributes)
  end
  
  it "should return expected hash representation of given model object" do
    @model.to_hash.should eql(@attributes)
  end
  
  after(:each) do
    nilize(@attributes, @model)
  end
end

describe Twitter::User, ".find" do
  before(:each) do
    @twitter = Twitter::Client.from_config 'config/twitter.yml'
    @id = 2423423
    @screen_name = 'ascreenname'
    @expected_user = Twitter::User.new(:id => @id, :screen_name => @screen_name)
  end
  
  it "should invoke given Twitter::Client's #user method with expected arguments" do
		# case where id => @id
    @twitter.should_receive(:user).with(@id).and_return(@expected_user)
    user = Twitter::User.find(@id, @twitter)
    user.should eql(@expected_user)
    
    # case where id => @screen_name, which is also valid
    @twitter.should_receive(:user).with(@screen_name).and_return(@expected_user)
    user = Twitter::User.find(@screen_name, @twitter)
    user.should eql(@expected_user)
  end
  
  after(:each) do
    nilize(@twitter, @id, @screen_name, @expected_user)
  end
end

describe Twitter::Status, ".find" do
  before(:each) do
    @twitter = Twitter::Client.from_config 'config/twitter.yml'
    @id = 9439843
    @text = 'My crummy status message'
    @user = Twitter::User.new(:id => @id, :screen_name => @screen_name)
    @expected_status = Twitter::Status.new(:id => @id, :text => @text, :user => @user)
  end
  
  it "should invoke given Twitter::Client's #status method with expected arguments" do
    @twitter.should_receive(:status).with(:get, @id).and_return(@expected_status)
    status = Twitter::Status.find(@id, @twitter)
    status.should eql(@expected_status)
  end
  
  after(:each) do
    nilize(@twitter, @id, @text, @user, @expected_status)
  end
end

describe Test::Model, "#bless" do
  before(:each) do
    @twitter = Twitter::Client.from_config('config/twitter.yml')
    @model = Test::Model.new
  end
  
  it "should delegate to #basic_bless" do
    @model.should_receive(:basic_bless).and_return(@twitter)
    @model.bless(@twitter)
  end
  
  it "should set client attribute of self" do
    @model.should_receive(:client=).once
    @model.bless(@twitter)
  end
  
  after(:each) do
    nilize(@model, @twitter)
  end
end

describe Twitter::User, "#is_me?" do
  before(:each) do
    @twitter = Twitter::Client.from_config('config/twitter.yml')
    @user_not_me = Twitter::User.new(:screen_name => 'notmylogin')
    @user_me = Twitter::User.new(:screen_name => @twitter.instance_eval("@login"))
    @user_not_me.bless(@twitter)
    @user_me.bless(@twitter)
  end
  
  it "should return true when Twitter::User object represents authenticated user of client context" do
    @user_me.is_me?.should be_true
  end
  
  it "should return false when Twitter::User object does not represent authenticated user of client context" do
    @user_not_me.is_me?.should be_false
  end
  
  after(:each) do
    nilize(@twitter, @user_not_me, @user_me)
  end
end

describe Twitter::User, "#bless(client)" do
  before(:each) do
    @twitter = Twitter::Client.from_config('config/twitter.yml')
    @user_not_me = Twitter::User.new(:screen_name => 'notmylogin')
    @user_me = Twitter::User.new(:screen_name => @twitter.instance_eval("@login"))
  end
  
  it "should add a followers method" do
    @user_me.should_not respond_to?(:followers)
    @user_me.bless(@twitter)
    @user_me.should respond_to?(:followers)
  end
  
  it "should not add a followers method" do
    @user_not_me.should_not respond_to?(:followers)
    @user_not_me.bless(@twitter)
    @user_not_me.should_not respond_to?(:followers)
  end
  
  after(:each) do
    nilize(@twitter, @user_not_me, @user_me)
  end
end

describe Twitter::User, "#friends" do
  before(:each) do
    @twitter = Twitter::Client.from_config('config/twitter.yml')
    @id = 5701682
    @user = Twitter::User.new(:id => @id, :screen_name => 'twitter4r')
    @user.bless(@twitter)
  end
  
  it "should delegate to @client.user(@id, :friends)" do
    @twitter.should_receive(:user).with(@id, :friends)
    @user.friends
  end
  
  after(:each) do
    nilize(@twitter, @id, @user)
  end
end

describe Twitter::User, "#followers" do
  before(:each) do
    @twitter = Twitter::Client.from_config('config/twitter.yml')
    @id = 5701682
    @user = Twitter::User.new(:id => @id, :screen_name => 'twitter4r')    
    @user.bless(@twitter)
  end
  
  it "should delegate to @client.my(:followers)" do
    @twitter.should_receive(:my).with(:followers)
    @user.followers
  end
  
  after(:each) do
    nilize(@twitter, @id, @user)    
  end
end

describe Test::Model, "#to_i" do
  before(:each) do
  	@id = 234324285
  	class Test::Model
  		attr_accessor :id
  	end
    @model = Test::Model.new(:id => @id)
  end
 	
  it "should return @id attribute" do
    @model.to_i.should eql(@id)
  end
  
  after(:each) do
    nilize(@model, @id)
  end
end

describe Test::Model, "#to_s" do
  before(:each) do
  	class Test::Model
  		attr_accessor :text
  	end
  	@text = 'Some text for the message body here'
    @model = Test::Model.new(:text => @text)
  end
  
  it "should return expected text when a @text attribute exists for the model" do
    @model.to_s.should eql(@text)
  end
  
  after(:each) do
    nilize(@model)
  end
end

describe Twitter::Message, ".find" do
  it "should raise NotImplementedError due to Twitter (as opposed to Twitter4R) API limitation" do
    lambda {
    	Twitter::Message.find(123, nil)
    }.should raise_error(NotImplementedError)
  end
end

describe Twitter::Status, ".create" do
  before(:each) do
    @twitter = client_context
    @text = 'My status update'
    @status = Twitter::Status.new(:text => @text, :client => @twitter)
  end
  
  it "should invoke #status(:post, text) on client context given" do
    @twitter.should_receive(:status).with(:post, @text).and_return(@status)
    Twitter::Status.create(:text => @text, :client => @twitter)
  end
  
  it "should raise an ArgumentError when no client is given in params" do
    lambda {
    	Twitter::Status.create(:text => @text)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError when no text is given in params" do
  	@twitter.should_receive(:is_a?).with(Twitter::Client)
    lambda {
    	Twitter::Status.create(:client => @twitter)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError when text given in params is not a String" do
    lambda {
    	Twitter::Status.create(:client => @twitter, :text => 234493)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError when client context given in params is not a Twitter::Client object" do
    lambda {
    	Twitter::Status.create(:client => 'a string instead of a Twitter::Client', :text => @text)
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@twitter, @text, @status)
  end
end

describe Twitter::Message, ".create" do
  before(:each) do
    @twitter = client_context
    @text = 'Just between you and I, Lantana and Gosford Park are two of my favorite movies'
    @recipient = Twitter::User.new(:id => 234958)
    @message = Twitter::Message.new(:text => @text, :recipient => @recipient)
  end
  
  it "should invoke #message(:post, text, recipient) on client context given" do
    @twitter.should_receive(:message).with(:post, @text, @recipient).and_return(@message)
    Twitter::Message.create(:client => @twitter, :text => @text, :recipient => @recipient)
  end
  
  it "should raise an ArgumentError if no client context is given in params" do
    lambda {
    	Twitter::Message.create(:text => @text, :recipient => @recipient)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if client conext given in params is not a Twitter::Client object" do
    lambda {
    	Twitter::Message.create(
    		:client => 3.14159, 
    		:text => @text, 
    		:recipient => @recipient)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if no text is given in params" do
  	@twitter.should_receive(:is_a?).with(Twitter::Client)
    lambda {
    	Twitter::Message.create(
    		:client => @twitter,
    		:recipient => @recipient)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if text given in params is not a String" do
    @twitter.should_receive(:is_a?).with(Twitter::Client)
    lambda {
    	Twitter::Message.create(
    		:client => @twitter,
    		:text => Object.new,
    		:recipient => @recipient)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if no recipient is given in params" do
    @text.should_receive(:is_a?).with(String)
    lambda {
    	Twitter::Message.create(
    		:client => @twitter,
    		:text => @text)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if recipient given in params is not a Twitter::User, Integer or String object" do
    @text.should_receive(:is_a?).with(String)
    lambda {
    	Twitter::Message.create(
    		:client => @twitter,
    		:text => @text,
    		:recipient => 3.14159)
    }.should raise_error(ArgumentError)
  end
  
  after(:each) do
    nilize(@twitter, @text, @recipient, @message)
  end
end

describe Twitter::User, "#befriend" do
  before(:each) do
    @twitter = client_context
    @user = Twitter::User.new(
    	:id => 1234, 
    	:screen_name => 'mylogin',
    	:client => @twitter)
    @friend = Twitter::User.new(
    	:id => 5678, 
    	:screen_name => 'friend',
    	:client => @twitter)
  end
  
  it "should invoke #friend(:add, user) on client context" do
    @twitter.should_receive(:friend).with(:add, @friend).and_return(@friend)
    @user.befriend(@friend)
  end
  
  after(:each) do
    nilize(@twitter, @user, @friend)
  end
end

describe Twitter::User, "#defriend" do
  before(:each) do
    @twitter = client_context
    @user = Twitter::User.new(
    	:id => 1234, 
    	:screen_name => 'mylogin',
    	:client => @twitter)
    @friend = Twitter::User.new(
    	:id => 5678, 
    	:screen_name => 'friend',
    	:client => @twitter)
  end
  
  it "should invoke #friend(:remove, user) on client context" do
    @twitter.should_receive(:friend).with(:remove, @friend).and_return(@friend)
    @user.defriend(@friend)
  end
  
  after(:each) do
    nilize(@twitter, @user, @friend)
  end
end

describe Twitter::Status, "#to_s" do
  before(:each) do
	  @text = 'Aloha'
    @status = Twitter::Status.new(:text => @text)
  end
  
  it "should render text attribute" do
    @status.to_s.should be(@text)
  end
  
  after(:each) do
    nilize(@text, @status)
  end
end

describe Twitter::Message, "#to_s" do
  before(:each) do
	  @text = 'Aloha'
    @message = Twitter::Message.new(:text => @text)
  end
  
  it "should render text attribute" do
    @message.to_s.should be(@text)
  end
  
  after(:each) do
    nilize(@text, @message)
  end
end
