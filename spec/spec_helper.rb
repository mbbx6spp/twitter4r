require 'spec'
require 'twitter'

# Add helper methods here if relevant to multiple _spec.rb files

# Spec helper that returns the project root directory as absolute path string
def project_root_dir
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

# Spec helper that returns stubbed <tt>Net::HTTP</tt> object 
# with given <tt>response</tt> and <tt>obj_stubs</tt>.
# The <tt>host</tt> and <tt>port</tt> are used to initialize 
# the Net::HTTP object.
def stubbed_net_http(response, obj_stubs = {}, host = 'twitter.com', port = 80)
  http = Net::HTTP.new(host, port)
  Net::HTTP.stub!(:new).and_return(http)
  http.stub!(:request).and_return(response)
  http
end

# Spec helper that returns a mocked <tt>Net::HTTP</tt> object and 
# stubs out the <tt>request</tt> method to return the given 
# <tt>response</tt>
def mas_net_http(response)
  http = mock(Net::HTTP)
  Net::HTTP.stub!(:new).and_return(http)
  http.stub!(:request).and_return(response)
  http.stub!(:start).and_yield(http)
  http
end

# Spec helper that returns a mocked <tt>Net::HTTP::Get</tt> object and 
# stubs relevant class methods and given <tt>obj_stubs</tt> 
# for endo-specing
def mas_net_http_get(obj_stubs = {})
  request = Spec::Mocks::Mock.new(Net::HTTP::Get)
  Net::HTTP::Get.stub!(:new).and_return(request)
  obj_stubs.each do |method, value|
    request.stub!(method).and_return(value)
  end
  request
end

# Spec helper that returns a mocked <tt>Net::HTTP::Post</tt> object and 
# stubs relevant class methods and given <tt>obj_stubs</tt> 
# for endo-specing
def mas_net_http_post(obj_stubs = {})
  request = Spec::Mocks::Mock.new(Net::HTTP::Post)
  Net::HTTP::Post.stub!(:new).and_return(request)
  obj_stubs.each do |method, value|
    request.stub!(method).and_return(value)
  end
  request
end

# Spec helper that returns a mocked <tt>Net::HTTPResponse</tt> object and 
# stubs given <tt>obj_stubs</tt> for endo-specing.
# 
def mas_net_http_response(status = :success, 
                          body = '', 
                          obj_stubs = {})
  response = Spec::Mocks::Mock.new(Net::HTTPResponse)
  response.stub!(:body).and_return(body)
  case status
  when :success || 200
    _create_http_response(response, "200", "OK")
  when :created || 201
    _create_http_response(response, "201", "Created")
  when :redirect || 301
    _create_http_response(response, "301", "Redirect")
  when :not_authorized || 403
    _create_http_response(response, "403", "Not Authorized")
  when :file_not_found || 404
    _create_http_response(response, "404", "File Not Found")
  when :server_error || 500
    _create_http_response(response, "500", "Server Error")
  end
  response
end

# Local helper method to DRY up code.
def _create_http_response(mock_response, code, message)
  mock_response.stub!(:code).and_return(code)
  mock_response.stub!(:message).and_return(message)
end
