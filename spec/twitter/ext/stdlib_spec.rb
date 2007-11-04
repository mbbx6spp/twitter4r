require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Hash, "#to_http_str" do
  before(:each) do
    @http_params = {:id => 'otherlogin', :since_id => 3953743, :full_name => 'Lucy Cross'}
    @id_regexp = Regexp.new("id=#{URI.encode(@http_params[:id].to_s)}")
    @since_id_regexp = Regexp.new("since_id=#{URI.encode(@http_params[:since_id].to_s)}")
    @full_name_regexp = Regexp.new("full_name=#{URI.encode(@http_params[:full_name].to_s)}")
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
