require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Twitter::Client, ".configure" do
  it "should respond to :configure class method" do
    Twitter::Client.respond_to?(:configure).should be(true)
  end  

  it "should not accept calls that do not specify blocks" do
    lambda {
      Twitter::Client.configure()
    }.should raise_error(ArgumentError)
  end  
end

describe Twitter::Client, ".configure with mocked @config" do
  before(:each) do
    @block_invoked = false
    @conf_yielded = false
    @conf = mock(Twitter::Config)
    @block = Proc.new do |conf| 
      @block_invoked = true
      @conf_yielded = true if conf.is_a?(Twitter::Config)
    end
    Twitter::Config.stub!(:new).and_return(@conf)
  end
  
  it "should not raise an error when passing block" do
    lambda {
      Twitter::Client.configure(&@block)
    }.should_not raise_error
  end
  
  it "should yield a Twitter::Client object to block" do
    Twitter::Client.configure(&@block)
    @block_invoked.should be(true)
    @conf_yielded.should be(true)
  end
  
  after(:each) do
    nilize(@block, @block_invoked, @conf, @conf_yielded)
  end
end

describe Twitter::Config, "#eql?" do
  before(:each) do
    @protocol = :ssl
    @host = 'twitter.com'
    @port = 443
    @proxy_host = 'myproxy.host'
    @proxy_port = 8080
    attrs = {
      :protocol => @protocol,
      :host => @host,
      :port => @port,
      :proxy_host => @proxy_host,
      :proxy_port => @proxy_port,
    }
    @obj = Twitter::Config.new(attrs)
    @other = Twitter::Config.new(attrs)
    
    @different = stubbed_twitter_config(Twitter::Config.new, attrs.merge(:proxy_host => 'different.proxy'))
    @same = @obj
  end
  
  it "should return true for two logically equivalent objects" do
    @obj.should be_eql(@other)
    @other.should be_eql(@obj)
  end
  
  it "should return false for two logically different objects" do
    @obj.should_not be_eql(@different)
    @different.should_not be_eql(@obj)
    @other.should_not be_eql(@different)
    @different.should_not be_eql(@other)
  end
  
  it "should return true for references to the same object in memory" do
    @obj.should eql(@same)
    @same.should eql(@obj)
    @other.should eql(@other)
  end
  
  after(:each) do
    nilize(@protocol, @host, @port, @proxy_host, @proxy_port, @obj, @other, @different, @same)
  end
end
