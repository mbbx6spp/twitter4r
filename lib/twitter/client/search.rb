class Twitter::Client

  @@SEARCH_URIS = {
    :basic => "/search.json",
  }

  # Provides access to Twitter's Search API.
  # 
  # Example:
  #  # For keyword search
  #  iterator = @twitter.search(:q => "coworking")
  #  while (tweet = iterator.next)
  #    puts tweet.text
  #  end
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:received+
  # * +:sent+
  def search(options = {})
#    raise ArgumentError, "Invalid messaging action: #{action}"
    uri = @@SEARCH_URIS[:basic]
    response = http_connect(nil, false, :search) {|conn|	create_http_get_request(uri, options) }
    json = JSON.parse(response.body)
    bless_models(Twitter::Status.unmarshal(JSON.dump(json["results"])))
  end
end
