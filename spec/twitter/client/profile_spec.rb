require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#profile" do
  before(:each) do
    @twitter = client_context
    @user_attrs = {
      :id => "JaneEyre",
      :login => "Jane Eyre",
      :url => "http://janeeyrerocks.co.uk",
      :location => "Thornfield Manor",
    }
    # name, email, url, location, description
    @info_attrs = {
      :name => "Jane Eyre", 
      :email => "jane.eyre@gmail.co.uk", 
      :url => "http://janeeyrerocks.co.uk",
      :location => "Thornfield Manor",
      :description => "Governess who falls for slave-trade aristocrat with French lovechild he doesn't acknowledge & wife locked in damp attic with keeper.",
    }
    # background_color, text_color, link_color, sidebar_fill_color, sidebar_border_color
    @colors_attrs = {
      :background_color => "#ffffff",
      :text_color => "#101010",
      :link_color => "#990000",
    }
    # value
    @device_attrs = {
      :value => "sms",
    }
    @user = Twitter::User.new
    @uris = Twitter::Client.class_eval("@@PROFILE_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @json = JSON.unparse(@user_attrs)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)

    Net::HTTP.stub!(:new).and_return(@connection)
    Twitter::User.stub!(:unmarshal).and_return(@user)
  end
  
  it "should invoke #http_connect with expected arguments for :info case" do
  	@twitter.should_receive(:http_connect).with(@info_attrs.to_http_str).and_return(@response)
    @twitter.profile(:info, @info_attrs)
  end

  it "should invoke #http_connect with expected arguments for :colors case" do
  	@twitter.should_receive(:http_connect).with(@colors_attrs.to_http_str).and_return(@response)
    @twitter.profile(:colors, @colors_attrs)
  end
  
  it "should invoke #http_connect with expected arguments for :device case" do
  	@twitter.should_receive(:http_connect).with(@device_attrs.to_http_str).and_return(@response)
    @twitter.profile(:info, @device_attrs)
  end
  
  it "should create expected HTTP POST request for :info case" do
    @twitter.should_receive(:create_http_post_request).with(@uris[:info]).and_return(@request)
    @twitter.profile(:info, @info_attrs)
  end
  
  it "should create expected HTTP POST request for :colors case" do
    @twitter.should_receive(:create_http_post_request).with(@uris[:colors]).and_return(@request)
    @twitter.profile(:colors, @colors_attrs)
  end
  
  it "should create expected HTTP POST request for :device case" do
    @twitter.should_receive(:create_http_post_request).with(@uris[:device]).and_return(@request)
    @twitter.profile(:device, @device_attrs)
  end

  it "should bless returned Twitter::User object for :info case" do
    @twitter.should_receive(:bless_model).with(@user)
    @twitter.profile(:info, @info_attrs)
  end

  it "should bless returned Twitter::User object for :colors case" do
    @twitter.should_receive(:bless_model).with(@user)
    @twitter.profile(:colors, @colors_attrs)
  end

  it "should bless returned Twitter::User object for :device case" do
    @twitter.should_receive(:bless_model).with(@user)
    @twitter.profile(:device, @device_attrs)
  end
  
  it "should raise an ArgumentError when giving an invalid profile action"
  
  after(:each) do
    nilize(@twitter, @uris, @request, @response, @connection, @sender, @recipient, @user, @attributes)
  end
end
