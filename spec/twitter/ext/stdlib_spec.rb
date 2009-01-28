require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Hash, "#to_http_str" do
  before(:each) do
    @http_params = {:id => 'otherlogin', :since_id => 3953743, :full_name => 'Lucy Cross'}
    @id_regexp = Regexp.new("id=#{CGI.escape(@http_params[:id].to_s)}")
    @since_id_regexp = Regexp.new("since_id=#{CGI.escape(@http_params[:since_id].to_s)}")
    @full_name_regexp = Regexp.new("full_name=Lucy\\+Cross")
  end
  
  it "should generate expected URL encoded string" do
    http_str = @http_params.to_http_str
    http_str.should match(@id_regexp)
    http_str.should match(@since_id_regexp)
    http_str.should match(@full_name_regexp)
  end
  
  after(:each) do
    @http_params = nil
    @id_kv_str, @since_id_kv_str, @full_name_kv_str = nil
  end
end

describe Time, "#to_s" do
  before(:each) do
    @time = Time.now
    @expected_string = @time.rfc2822
  end
  
  it "should output RFC2822 compliant string" do
    time_string = @time.to_s
    time_string.should eql(@expected_string)
  end
  
  it "should respond to #old_to_s" do
    @time.should respond_to(:old_to_s)
  end
  
  after(:each) do
    nilize(@time, @expected_string)
  end
end

# TODO: figure out how to stub the gem method to do what we want rather than this monstrousity.  It is dependent on the system installation, which is always a bad thing.  For now it will do so we can ship with 100% C0 coverage.
describe Kernel, "#gem_present?" do
  before(:each) do
    @present_gem = "rake"
    @uninstalled_gem = "uninstalled-gem-crap"
  end
  
  it "should return true when a gem isn't present on system" do
    gem_present?(@present_gem).should eql(true)
  end
  
  it "should return false when a gem isn't present on system" do
    gem_present?(@uninstalled_gem).should eql(false)
  end
end

