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
  
  it "should delegate to @client.user(@id, :followers)" do
    @twitter.should_receive(:user).with(@id, :followers)
    @user.followers
  end
  
  after(:each) do
    nilize(@twitter, @id, @user)    
  end
end

# TODO: Add specifications for ModelMix#to_int
