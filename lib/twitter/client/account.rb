class Twitter::Client
  @@ACCOUNT_URIS = {
    :rate_limit_status => '/account/rate_limit_status',
  }
  
  # Provides access to the Twitter rate limit status API.
  # 
  # You can find out information about your account status.  Currently the only 
  # supported type of account status is the <tt>:rate_limit_status</tt> which 
  # returns a <tt>Twitter::RateLimitStatus</tt> object.
  # 
  # Example:
  #  account_status = client.account_info
  #  puts account_status.remaining_hits
  def account_info(type = :rate_limit_status)
    connection = create_http_connection
    connection.start do |connection|
      response = http_connect do |conn|
        create_http_get_request(@@ACCOUNT_URIS[type])
      end
      bless_models(Twitter::RateLimitStatus.unmarshal(response.body))
    end
  end
end
