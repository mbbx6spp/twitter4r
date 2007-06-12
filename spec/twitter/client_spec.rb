require File.join(File.dirname(__FILE__), '..', 'spec_helper')

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

describe "Twitter::Client#timeline(:public)" do
  before(:each) do
    @host = 'twitter.com'
    @port = 443
    @protocol = :http
    @proxy_host = 'myproxy.host'
    @proxy_port = 8080
    
    Twitter::Client.configure do |conf|
      conf.host = @host
      conf.port = @port
      conf.protocol = @protocol
      conf.proxy_host = @proxy_host
      conf.proxy_port = @proxy_port
    end

    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, '[]')
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @login = @client.instance_eval("@login")
    @password = @client.instance_eval("@password")
  end
 
  it "should connect to the Twitter service via HTTP connection" do
    Net::HTTP.should_receive(:new).with(@host, @port, @proxy_host, @proxy_port).once.and_return(@http)
  	@client.timeline(:public)
  end
  
  it " should send HTTP Basic Authentication credentials" do
    @request.should_receive(:basic_auth).with(@login, @password).once
    @client.timeline(:public)
  end
end

describe "Twitter::Client#unmarshall_statuses" do
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
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  it "should return expected populated Twitter::Status object values in an Array" do
    statuses = @client.send(:unmarshall_statuses, [@json_hash])
    statuses.should_not be(nil)
    statuses.should have(1).entries
    statuses.first.should eql(@status)
  end
end

describe "Twitter::Client#unmarshall_user" do
  before(:each) do
    @json_hash = { "name" => "Lucy Snowe",
                   "description" => "School Mistress Entrepreneur",
                   "location" => "Villette",
                   "url" => "http://villetteschoolforgirls.com",
                   "id" => 859303,
                   "protected" => true,
                   "screen_name" => "LucyDominatrix", }
    @user = Twitter::User.new @json_hash
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  it "should return expected populated Twitter::User object value" do
    user = @client.send(:unmarshall_user, @json_hash)
    user.should eql(@user)
  end
end

describe "Twitter::Client#timeline_request upon 200 HTTP response" do
  before(:each) do
    @request = mas_net_http_get :basic_auth => nil
    @response = mas_net_http_response # defaults to :success
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
    
    JSON.stub!(:parse).and_return({})
  end
  
  it "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
      @client.send(:timeline_request, type, @http)
    end
  end
end

describe "Twitter::Client#timeline_request upon 403 HTTP response" do
  before(:each) do
    @request = mas_net_http_get :basic_auth => nil
    @response = mas_net_http_response :not_authorized
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
  end
  
  it "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      lambda do
        Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
        @client.send(:timeline_request, type, @http)
      end.should raise_error(Twitter::RESTError)
    end
  end
end

describe "Twitter::Client#timeline_request upon 500 HTTP response" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:server_error)
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
  end
  
  it "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      lambda do
        Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
        @client.send(:timeline_request, type, @http)
      end.should raise_error(Twitter::RESTError)
    end
  end
end

describe "Twitter::Client#timeline_request upon 404 HTTP response" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:file_not_found)
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
  end
  
  it "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      lambda do
        Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
        @client.send(:timeline_request, type, @http)
      end.should raise_error(Twitter::RESTError)
    end
  end
end

describe "Twitter::Client#update(msg) upon 200 HTTP response" do
  before(:each) do
    @request = mas_net_http_post(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @expected_uri = Twitter::Client.class_eval("@@URIS[:update]")
    
    @message = "We love Jodhi May!"
  end
  
  it "should make POST HTTP request to appropriate URL" do
    Net::HTTP::Post.should_receive(:new).with(@expected_uri).and_return(@request)
    @client.update(@message)
  end
end

describe "Twitter::Client#update(msg) upon 500 HTTP response" do
  before(:each) do
    @request = mas_net_http_post(:basic_auth => nil)
    @response = mas_net_http_response(:server_error)
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @expected_uri = Twitter::Client.class_eval("@@URIS[:update]")
    
    @message = "We love Jodhi May!"
  end
  
  it "should make POST HTTP request to appropriate URL" do
    lambda do
      Net::HTTP::Post.should_receive(:new).with(@expected_uri).and_return(@request)
      @client.update(@message)
    end.should raise_error(Twitter::RESTError)
  end
end

describe "Twitter::Client#public_timeline" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  it "should delegate work to Twitter::Client#public(:public)" do
    @client.should_receive(:timeline).with(:public).once
    @client.public_timeline
  end
end

describe "Twitter::Client#friend_timeline" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  it "should delegate work to Twitter::Client#public(:friends)" do
    @client.should_receive(:timeline).with(:friends).once
    @client.friend_timeline
  end
end

describe "Twitter::Client#friend_statuses" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  it "should delegate work to Twitter::Client#public(:friends_statuses)" do
    @client.should_receive(:timeline).with(:friends_statuses).once
    @client.friend_statuses
  end
end

describe "Twitter::Client#follower_statuses" do
  before(:each) do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  it "should delegate work to Twitter::Client#public(:followers)" do
    @client.should_receive(:timeline).with(:followers).once
    @client.follower_statuses
  end
end

describe "Twitter::Client#send_direct_message" do
  before(:each) do
    @request = mas_net_http_post(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    
    @login = @client.instance_eval("@login")
    @password = @client.instance_eval("@password")
    
    @user = mock(Twitter::User)
    @user.stub!(:screen_name).and_return("twitter4r")

    @message = "This is a test direct message from twitter4r RSpec specifications"
    @expected_uri = '/direct_messages/new.json'
    @expected_params = "user=#{@user.screen_name}&text=#{URI.escape(@message)}"
  end
  
  it "should convert given Twitter::User object to screen name" do
    @user.should_receive(:screen_name).once
    @client.send_direct_message(@user, @message)
  end
  
  it "should POST to expected URI" do
    Net::HTTP::Post.should_receive(:new).with(@expected_uri).once.and_return(@request)
    @client.send_direct_message(@user, @message)
  end
  
  it "should login via HTTP Basic Authentication using expected credentials" do
    @request.should_receive(:basic_auth).with(@login, @password).once
    @client.send_direct_message(@user, @message)
  end
  
  it "should make POST request with expected URI escaped parameters" do
    @http.should_receive(:request).with(@request, @expected_params).once.and_return(@response)
    @client.send_direct_message(@user, @message)
  end
end

