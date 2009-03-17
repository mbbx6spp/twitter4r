require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe :rest_api_request, :shared => true do
  before(:each) do
    
  end
  it "should invoke #http_connect with expected arguments"
  it "should create HTTP request of expected method"
  it "should bless returned model of expected type"
end

describe Twitter::Client, "#end" do
  describe "keywords case" do
    def expected_http_method; :get; end
    def expected_model; Twitter::Status; end
    def expected_model_in_array?; true; end
    def expected_http_connect_arguments; {}; end
#    should_behave_like :rest_api_request
  end
  
  describe "invalid" do
    it "should raise an ArgumentError when giving an invalid search action"
  end
end
