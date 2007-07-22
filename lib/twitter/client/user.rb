class Twitter::Client
  @@USER_URIS = {
  	:info => '/users/show',
  	:friends => '/statuses/friends.json',
  	:followers => '/statuses/followers.json',
  }
  
  # Provides access to Twitter's User APIs
  # 
  # Returns user instance for the <tt>id</tt> given.  The <tt>id</tt>
  # can either refer to the numeric user ID or the user's screen name.
  # 
  # For example,
  #  @twitter.user(234943) #=> Twitter::User object instance for user with numeric id of 234943
  #  @twitter.user('mylogin') #=> Twitter::User object instance for user with screen name 'mylogin'
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:info+
  # * +:friends+
  # 
  # +Note:+ You should not use this method to attempt to retrieve the 
  # authenticated user's followers.  Please use any of the following 
  # ways of accessing this list:
  #  followers = client.my(:followers)
  # OR
  #  followers = client.my(:info).followers
  def user(id, action = :info)
    raise ArgumentError, "Invalid user action: #{action}" unless @@USER_URIS.keys.member?(action)
    raise ArgumentError, "Unable to retrieve followers for user: #{id}" if action.eql?(:followers) and not id.eql?(@login)
    id = id.to_i if id.is_a?(Twitter::User)
  	response = http_connect {|conn| create_http_get_request(@@USER_URIS[action], :id => id) }
  	bless_models(Twitter::User.unmarshal(response.body))
  end
  
  # Syntactic sugar for queries relating to authenticated user in Twitter's User API
  # 
  # When <tt>action</tt> is:
  # * <tt>:info</tt> - Returns user instance for the authenticated user.
  # * <tt>:friends</tt> - Returns Array of users that are authenticated user's friends
  # * <tt>:followers</tt> - Returns Array of users that are authenticated user's followers
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:info+
  # * +:friends+
  # * +:followers+
  def my(action)
    raise ArgumentError, "Invalid user action: #{action}" unless @@USER_URIS.keys.member?(action)
  	response = http_connect {|conn| create_http_get_request(@@USER_URIS[action], :id => @login) }
  	users = Twitter::User.unmarshal(response.body)
  	bless_models(users)
  end
end
