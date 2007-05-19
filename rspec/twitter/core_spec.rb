require File.join(File.dirname(__FILE__), '..', 'spec_helper')

context "Twitter::ClassUtilMixin mixed-in class" do
  setup do
    class TestClass
      include Twitter::ClassUtilMixin
      attr_accessor :var1, :var2, :var3
    end
    @init_hash = { :var1 => 'val1', :var2 => 'val2', :var3 => 'val3' }
  end
  
  specify "should have Twitter::ClassUtilMixin as an included module" do
    TestClass.included_modules.member?(Twitter::ClassUtilMixin).should.eql true
  end

  specify "should set attributes passed in the hash to TestClass.new" do
    test = TestClass.new(@init_hash)
    @init_hash.each do |key, val|
      test.send(key).should.eql val
    end
  end
  
  specify "should not set attributes passed in the hash that are not attributes in TestClass.new" do
    test = nil
    lambda { test = TestClass.new(@init_hash.merge(:var4 => 'val4')) }.should_not_raise
    test.respond_to?(:var4).should.eql false
  end
end

context "Twitter::RESTError#to_s" do
  setup do
    @hash = { :code => 200, :message => 'OK', :uri => 'http://test.host/bla' }
    @error = Twitter::RESTError.new(@hash)
    @expected_message = "HTTP #{@hash[:code]}: #{@hash[:message]} at #{@hash[:uri]}"
  end
  
  specify "should return @expected_message" do
    @error.to_s.should.eql @expected_message
  end
end

context "Twitter::Client" do
  setup do
    @init_hash = { :login => 'user', :password => 'pass' }
  end

  specify ".new should accept login and password as initializer hash keys and set the values to instance values" do
    client = nil
    lambda do
      client = Twitter::Client.new(@init_hash)
    end.should_not_raise
    client.send(:login).should.eql @init_hash[:login]
    client.send(:password).should.eql @init_hash[:password]
  end  
end

context "Twitter::Client.config" do
  setup do
    @config_hash = { :host => 'test.host',
                     :port => 443,
                     :use_ssl => true, }
  end
  
  specify "should override @@HOST and @@PORT if supplied" do
    Twitter::Client.config @config_hash
    host = Twitter::Client.class_eval("@@HOST")
    host.should.eql @config_hash[:host]
    port = Twitter::Client.class_eval("@@PORT")
    port.should.eql @config_hash[:port]
    ssl = Twitter::Client.class_eval("@@SSL")
    ssl.should.eql @config_hash[:use_ssl]
  end
  
  teardown do
    Twitter::Client.config :host => 'twitter.com', :port => 80, :use_ssl => false
  end
end

context "Twitter::Client#timeline(:public)" do
  setup do
    Twitter::Client.config(:port => 443, :use_ssl => false)
    @host = Twitter::Client.class_eval("@@HOST")
    @port = Twitter::Client.class_eval("@@PORT")

    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, '[]')
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @login = @client.instance_eval("@login")
    @password = @client.instance_eval("@password")
  end
 
  specify "should connect to the Twitter service via HTTP connection" do
    Net::HTTP.should_receive(:new).with(@host, @port).once.and_return(@http)
  	@client.timeline(:public)
  end
  
  specify " should send HTTP Basic Authentication credentials" do
    @request.should_receive(:basic_auth).with(@login, @password).once
    @client.timeline(:public)
  end
end

context "Twitter::Client#unmarshall_statuses" do
  setup do
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
  
  specify "should return expected populated Twitter::Status object values in an Array" do
    statuses = @client.send(:unmarshall_statuses, [@json_hash])
    statuses.should.have(1)
    statuses.first.should.eql? @status
  end
end

context "Twitter::Client#unmarshall_user" do
  setup do
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
  
  specify "should return expected populated Twitter::User object value" do
    user = @client.send(:unmarshall_user, @json_hash)
    user.should.eql? @user
  end
end

context "Twitter::Client#timeline_request upon 200 HTTP response" do
  setup do
    @request = mas_net_http_get :basic_auth => nil
    @response = mas_net_http_response # defaults to :success
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
    
    JSON.stub!(:parse).and_return({})
  end
  
  specify "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
      @client.send(:timeline_request, type, @http)
    end
  end
end

context "Twitter::Client#timeline_request upon 403 HTTP response" do
  setup do
    @request = mas_net_http_get :basic_auth => nil
    @response = mas_net_http_response :not_authorized
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
  end
  
  specify "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      lambda do
        Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
        @client.send(:timeline_request, type, @http)
      end.should_raise(Twitter::RESTError)
    end
  end
end

context "Twitter::Client#timeline_request upon 500 HTTP response" do
  setup do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:server_error)
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
  end
  
  specify "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      lambda do
        Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
        @client.send(:timeline_request, type, @http)
      end.should_raise(Twitter::RESTError)
    end
  end
end

context "Twitter::Client#timeline_request upon 404 HTTP response" do
  setup do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:file_not_found)
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @uris = Twitter::Client.class_eval("@@URIS")
  end
  
  specify "should make GET HTTP request to appropriate URL" do
    @uris.keys.each do |type|
      lambda do
        Net::HTTP::Get.should_receive(:new).with(@uris[type]).and_return(@request)
        @client.send(:timeline_request, type, @http)
      end.should_raise(Twitter::RESTError)
    end
  end
end

context "Twitter::Client#update(msg) upon 200 HTTP response" do
  setup do
    @request = mas_net_http_post(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @expected_uri = Twitter::Client.class_eval("@@URIS[:update]")
    
    @message = "We love Jodhi May!"
  end
  
  specify "should make POST HTTP request to appropriate URL" do
    Net::HTTP::Post.should_receive(:new).with(@expected_uri).and_return(@request)
    @client.update(@message)
  end
end

context "Twitter::Client#update(msg) upon 500 HTTP response" do
  setup do
    @request = mas_net_http_post(:basic_auth => nil)
    @response = mas_net_http_response(:server_error)
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
    @expected_uri = Twitter::Client.class_eval("@@URIS[:update]")
    
    @message = "We love Jodhi May!"
  end
  
  specify "should make POST HTTP request to appropriate URL" do
    lambda do
      Net::HTTP::Post.should_receive(:new).with(@expected_uri).and_return(@request)
      @client.update(@message)
    end.should_raise(Twitter::RESTError)
  end
end

context "Twitter::Client#public_timeline" do
  setup do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  specify "should delegate work to Twitter::Client#public(:public)" do
    @client.should_receive(:timeline).with(:public).once
    @client.public_timeline
  end
end

context "Twitter::Client#friend_timeline" do
  setup do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  specify "should delegate work to Twitter::Client#public(:friends)" do
    @client.should_receive(:timeline).with(:friends).once
    @client.friend_timeline
  end
end

context "Twitter::Client#friend_statuses" do
  setup do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  specify "should delegate work to Twitter::Client#public(:friends_statuses)" do
    @client.should_receive(:timeline).with(:friends_statuses).once
    @client.friend_statuses
  end
end

context "Twitter::Client#follower_statuses" do
  setup do
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response
    
    @http = mas_net_http(@response)
    @client = Twitter::Client.from_config 'config/twitter.yml'
  end
  
  specify "should delegate work to Twitter::Client#public(:followers)" do
    @client.should_receive(:timeline).with(:followers).once
    @client.follower_statuses
  end
end

context "Twitter::Client#send_direct_message" do
  setup do
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
  
  specify "should convert given Twitter::User object to screen name" do
    @user.should_receive(:screen_name).once
    @client.send_direct_message(@user, @message)
  end
  
  specify "should POST to expected URI" do
    Net::HTTP::Post.should_receive(:new).with(@expected_uri).once.and_return(@request)
    @client.send_direct_message(@user, @message)
  end
  
  specify "should login via HTTP Basic Authentication using expected credentials" do
    @request.should_receive(:basic_auth).with(@login, @password).once
    @client.send_direct_message(@user, @message)
  end
  
  specify "should make POST request with expected URI escaped parameters" do
    @http.should_receive(:request).with(@request, @expected_params).once.and_return(@response)
    @client.send_direct_message(@user, @message)
  end
end

context "Twitter::Status#eql?" do
  setup do
    @attr_hash = { :text => 'Status', :id => 34329594003, 
                   :user => { :name => 'Tess',
                              :description => "Unfortunate D'Urberville",
                              :location => 'Dorset',
                              :url => nil,
                              :id => 34320304,
                              :screen_name => 'maiden_no_more' }, 
                   :created_at => 'Wed May 02 03:04:54 +0000 2007'}
    @obj = Twitter::Status.new @attr_hash
    @other = Twitter::Status.new @attr_hash
  end
  
  specify "should return true when non-transient object attributes are eql?" do
    @obj.should.eql? @other
    @obj.eql?(@other).should.eql? true # for the sake of getting rcov to recognize this method is covered in the specs
  end

  specify "should return false when not all non-transient object attributes are eql?" do
    @other.created_at = Time.now.to_s
    @obj.should.not.eql? @other
    @obj.eql?(@other).should.eql? false # for the sake of getting rcov to recognize this method is covered in the specs
  end
  
  specify "should return true when comparing same object to itself" do
    @obj.should.eql? @obj
    @obj.eql?(@obj).should.eql? true # for the sake of getting rcov to recognize this method is covered in the specs
    @other.should.eql? @other
    @other.eql?(@other).should.eql? true # for the sake of getting rcov to recognize this method is covered in the specs
  end
end

context "Twitter::User#eql?" do
  setup do
    @attr_hash = { :name => 'Elizabeth Jane Newson-Henshard',
                   :description => "Wronged 'Daughter'",
                   :location => 'Casterbridge',
                   :url => nil,
                   :id => 6748302,
                   :screen_name => 'mayors_daughter_or_was_she?' }
    @obj = Twitter::User.new @attr_hash
    @other = Twitter::User.new @attr_hash
  end
  
  specify "should return true when non-transient object attributes are eql?" do
    @obj.should.eql? @other
    @obj.eql?(@other).should.eql? true
  end
  
  specify "should return false when not all non-transient object attributes are eql?" do
    @other.id = 1
    @obj.should.not.eql? @other
    @obj.eql?(@other).should.eql? false
  end
  
  specify "should return true when comparing same object to itself" do
    @obj.should.eql? @obj
    @obj.eql?(@obj).should.eql? true
    @other.should.eql? @other
    @obj.eql?(@obj).should.eql? true
  end
end
