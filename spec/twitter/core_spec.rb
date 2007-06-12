require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "Twitter::ClassUtilMixin mixed-in class" do
  before(:each) do
    class TestClass
      include Twitter::ClassUtilMixin
      attr_accessor :var1, :var2, :var3
    end
    @init_hash = { :var1 => 'val1', :var2 => 'val2', :var3 => 'val3' }
  end
  
  it "should have Twitter::ClassUtilMixin as an included module" do
    TestClass.included_modules.member?(Twitter::ClassUtilMixin).should be(true)
  end

  it "should set attributes passed in the hash to TestClass.new" do
    test = TestClass.new(@init_hash)
    @init_hash.each do |key, val|
      test.send(key).should eql(val)
    end
  end
  
  it "should not set attributes passed in the hash that are not attributes in TestClass.new" do
    test = nil
    lambda { test = TestClass.new(@init_hash.merge(:var4 => 'val4')) }.should_not raise_error
    test.respond_to?(:var4).should be(false)
  end
end

describe "Twitter::RESTError#to_s" do
  before(:each) do
    @hash = { :code => 200, :message => 'OK', :uri => 'http://test.host/bla' }
    @error = Twitter::RESTError.new(@hash)
    @expected_message = "HTTP #{@hash[:code]}: #{@hash[:message]} at #{@hash[:uri]}"
  end
  
  it "should return @expected_message" do
    @error.to_s.should eql(@expected_message)
  end
end

describe "Twitter::Status#eql?" do
  before(:each) do
    @id = 34329594003
    @attr_hash = { :text => 'Status', :id => @id, 
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
  
  it "should return true when non-transient object attributes are eql?" do
    @obj.should eql(@other)
  end

  it "should return false when not all non-transient object attributes are eql?" do
    @other.created_at = Time.now.to_s
    @obj.should_not eql(@other)
  end
  
  it "should return true when comparing same object to itself" do
    @obj.should eql(@obj)
    @other.should eql(@other)
  end
end

describe "Twitter::User#eql?" do
  before(:each) do
    @attr_hash = { :name => 'Elizabeth Jane Newson-Henshard',
                   :description => "Wronged 'Daughter'",
                   :location => 'Casterbridge',
                   :url => nil,
                   :id => 6748302,
                   :screen_name => 'mayors_daughter_or_was_she?' }
    @obj = Twitter::User.new @attr_hash
    @other = Twitter::User.new @attr_hash
  end
  
  it "should return true when non-transient object attributes are eql?" do
    @obj.should eql(@other)
  end
  
  it "should return false when not all non-transient object attributes are eql?" do
    @other.id = 1
    @obj.should_not eql(@other)
    @obj.eql?(@other).should be(false)
  end
  
  it "should return true when comparing same object to itself" do
    @obj.should eql(@obj)
    @other.should eql(@other)
  end
end
