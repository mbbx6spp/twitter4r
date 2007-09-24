require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Twitter::Client, "#messages" do
  before(:each) do
    @twitter = client_context
    @uris = Twitter::Client.class_eval("@@MESSAGING_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @response = mas_net_http_response(:success, "[]")
    @connection = mas_net_http(@response)
    Net::HTTP.stub!(:new).and_return(@connection)
    @messages = []
    Twitter::Message.stub!(:unmarshal).and_return(@messages)
    @page = 2
  end
  
  it "should create expected HTTP GET request for :received case" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:received]).and_return(@request)
    @twitter.messages(:received)
  end
  
  it "should bless the Array returned from Twitter for :received case" do
    @twitter.should_receive(:bless_models).with(@messages).and_return(@messages)
    @twitter.messages(:received)
  end
  
  it "should create expected HTTP GET request for :sent case" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:sent]).and_return(@request)
    @twitter.messages(:sent)
  end
  
  it "should bless the Array returned from Twitter for :sent case" do
    @twitter.should_receive(:bless_models).with(@messages).and_return(@messages)
    @twitter.messages(:sent)
  end
  
  it "should raise an ArgumentError when giving an invalid messaging action" do
    lambda {
      @twitter.messages(:crap)
    }.should raise_error(ArgumentError)
  end

  it "should accept an options Hash for paging" do
    lambda {
      @twitter.messages(:sent, :page => @page)
    }.should_not raise_error(Exception)
  end

  it "should generate expected GET HTTP request for paging case" do
    @twitter.should_receive(:create_http_get_request).with(@uris[:received] + "?page=#{@page}").and_return(@request)
    @twitter.messages(:received, :page => @page)
  end

  it "should bless models for paging case" do
    @twitter.should_receive(:bless_models).with(@messages).and_return(@messages)
    @twitter.messages(:sent, :page => @page)
  end
  
  after(:each) do
    nilize(@twitter, @uris, @request, @response, @connection, @messages)
  end
end

describe Twitter::Client, "#message" do
  before(:each) do
    @twitter = client_context
    @attributes = {
      :id => 34324, 
      :text => 'Randy, are you coming over later?', 
      :sender => {:id => 123, :screen_name => 'mylogin'},
      :recipient => {:id => 1234, :screen_name => 'randy'},
    }
    @message = Twitter::Message.new(@attributes)
    @uris = Twitter::Client.class_eval("@@MESSAGING_URIS")
    @request = mas_net_http_get(:basic_auth => nil)
    @json = JSON.unparse(@attributes)
    @response = mas_net_http_response(:success, @json)
    @connection = mas_net_http(@response)
    @source = Twitter::Client.class_eval("@@defaults[:source]")

    Net::HTTP.stub!(:new).and_return(@connection)
    Twitter::Message.stub!(:unmarshal).and_return(@message)
  end
  
  it "should invoke #http_connect with expected arguments for :post case" do
  	@twitter.should_receive(:http_connect).with({:text => @message.text, :user => @message.recipient.to_i, :source => @source}.to_http_str).and_return(@response)
    @twitter.message(:post, @message.text, @message.recipient)
  end
  
  it "should create expected HTTP POST request for :post case" do
    @twitter.should_receive(:create_http_post_request).with(@uris[:post]).and_return(@request)
    @twitter.message(:post, @message.text, @message.recipient)
  end
  
  it "should bless returned Twitter::Message object for :post case" do
    @twitter.should_receive(:bless_model).with(@message)
    @twitter.message(:post, @message.text, @message.recipient)
  end
  
  it "should create expected HTTP DELETE request for :delete case" do
    @twitter.should_receive(:create_http_delete_request).with(@uris[:delete], {:id => @message.to_i}).and_return(@request)
    @twitter.message(:delete, @message)
  end
  
  it "should bless returned Twitter::Message object for :delete case" do
    @twitter.should_receive(:bless_model).with(@message)
    @twitter.message(:delete, @message)
  end
  
  it "should invoke #to_i on message object passed in for :delete case" do
    @message.should_receive(:to_i).and_return(@message.id)
    @twitter.message(:delete, @message)
  end
  
  it "should raise an ArgumentError when giving an invalid messaging action" do
    lambda {
      @twitter.message(:crap, @message)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError for :post case if user argument is not supplied" do
    lambda {
      @twitter.message(:post, @message)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError for :post case if user argument is nil" do
    lambda {
      @twitter.message(:post, @message, nil)
    }.should raise_error(ArgumentError)
  end

  after(:each) do
    nilize(@twitter, @uris, @request, @response, @connection, @sender, @recipient, @message, @attributes)
  end
end
