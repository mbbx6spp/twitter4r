class Twitter::Client

  @@SEARCH_URIS = {
    
  }

  # Provides access to Twitter's Search API.
  # 
  # Example:
  #  # For keyword search
  #  iterator = @twitter.search(:keyword => "coworking")
  #  while (tweet = iterator.next)
  #    puts tweet.text
  #  end
  #  # For hashtag search
  #  iterator = @twitter.search(:hashtag => "coworking") # or :hashtag => "#coworking"
  #  iterator = @twitter.search(:
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:received+
  # * +:sent+
  def search(options = {})
#    raise ArgumentError, "Invalid messaging action: #{action}"
    uri = @@SEARCH_URIS[action]
    response = http_connect {|conn|	create_http_get_request(uri, options) }
    bless_models(Twitter::Status.unmarshal(response.body))
  end
  
  
end
