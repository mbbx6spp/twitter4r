# extra.rb contains features that are not considered part of the core library.
# This file is not imported by doing <tt>require('twitter')</tt>, so you will 
# need to import this file separately like:
#  require('twitter')
#  require('twitter/extras')

require('twitter')

class Twitter::Client
  @@FEATURED_URIS = {
    :users => 'http://twitter.com/statuses/featured.json'
  }
  
  # Provides access to the Featured Twitter API.
  # 
  # Currently the only value for <tt>type</tt> accepted is <tt>:users</tt>,
  # which will return an Array of blessed Twitter::User objects that 
  # represent Twitter's featured users.
  def featured(type)
    uri = @@FEATURED_URIS[type]
    response = http_connect {|conn| create_http_get_request(uri) }
    bless_models(Twitter::User.unmarshal(response.body))
  end
end

class Twitter::User
  class << self
    # Provides access to the Featured Twitter API via the Twitter4R Model 
    # interface.
    # 
    # The following lines of code are equivalent to each other:
    #  users1 = Twitter::User.features(client)
    #  users2 = client.featured(:users)
    # where <tt>users1</tt> and <tt>users2</tt> would be logically equivalent.
    def featured(client)
      client.featured(:users)
    end
  end
end
