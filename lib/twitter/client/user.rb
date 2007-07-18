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
  def user(id, action = :info)
  	response = http_connect {|conn| create_http_get_request(@@USER_URIS[action], :id => id) }
  	bless_models(Twitter::User.unmarshal(response.body))
  end
  
  # Syntactic sugar for queries relating to authenticated user in Twitter's User API
  # 
  # When <tt>action</tt> is:
  # * <tt>:info</tt> - Returns user instance for the authenticated user.
  # * <tt>:friends</tt> - Returns Array of users that are authenticated user's friends
  # * <tt>:followers</tt> - Returns Array of users that are authenticated user's followers
  def my(action)
  	response = http_connect {|conn| create_http_get_request(@@USER_URIS[action], :id => @login) }
  	json = response.body
  	users = Twitter::User.unmarshal(json)
  	bless_models(users)
  end
end
