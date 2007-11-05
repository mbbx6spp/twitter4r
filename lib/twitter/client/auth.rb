class Twitter::Client
  @@AUTHENTICATION_URIS = {
    :verify => '/account/verify_credentials',
  }
  
	# Provides access to the Twitter verify credentials API.
	# 
	# You can verify Twitter user credentials with minimal overhead using this method.
  # 
	# Example:
	#  client.authenticate?("osxisforlightweights", "l30p@rd_s^cks!")
	def authenticate?(login, password)
    verify_credentials(login, password)
	end
	
private
  def verify_credentials(username, passwd)
  	connection = create_http_connection
  	connection.start do |connection|
  	  request = create_http_get_request("#{@@AUTHENTICATION_URIS[:verify]}.json")
  		request.basic_auth(username, passwd)
  		response = connection.request(request)
  		response.is_a?(Net::HTTPSuccess) ? true : false
    end
  end
end

