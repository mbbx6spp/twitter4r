class Twitter::Client
  @@TIMELINE_URIS = {
    :public => '/statuses/public_timeline.json',
    :friends => '/statuses/friends_timeline.json',
    :friend => '/statuses/friends_timeline.json',
    :user => '/statuses/user_timeline.json',
    :me => '/statuses/user_timeline.json',
    :replies => '/statuses/replies.json',
  }

  # Provides access to Twitter's Timeline APIs
  # 
  # Returns timeline for given <tt>type</tt>.  
  # 
  # <tt>type</tt> can take the following values:
  # * <tt>public</tt>
  # * <tt>friends</tt> or <tt>friend</tt>
  # * <tt>user</tt> or <tt>me</tt>
  # 
  # <tt>:id</tt> is on key applicable to be defined in </tt>options</tt>:
  # * the id or screen name (aka login) for :friends
  # * the id or screen name (aka login) for :user
  # * meaningless for the :me case, since <tt>twitter.timeline_for(:user, 'mylogin')</tt> and <tt>twitter.timeline_for(:me)</tt> are the same assuming 'mylogin' is the authenticated user's screen name (aka login).
  # 
  # Examples:
  #  # returns the public statuses since status with id of 6543210
  #  twitter.timeline_for(:public, id => 6543210)
  #  # returns the statuses for friend with user id 43210
  #  twitter.timeline_for(:friend, :id => 43210)
  #  # returns the statuses for friend with screen name (aka login) of 'otherlogin'
  #  twitter.timeline_for(:friend, :id => 'otherlogin')
  #  # returns the statuses for user with screen name (aka login) of 'otherlogin'
  #  twitter.timeline_for(:user, :id => 'otherlogin')
  # 
  # <tt>options</tt> can also include the following keys:
  # * <tt>:id</tt> is the user ID, screen name of Twitter::User representation of a <tt>Twitter</tt> user.
  # * <tt>:since</tt> is a Time object specifying the date-time from which to return results for.  Applicable for the :friend, :friends, :user and :me cases.
  # * <tt>:count</tt> specifies the number of statuses to retrieve.  Only applicable for the :user case.
  # * <tt>since_id</tt> is the status id of the public timeline from which to retrieve statuses for <tt>:public</tt>.  Only applicable for the :public case.
  # 
  # You can also pass this method a block, which will iterate through the results
  # of the requested timeline and apply the block logic for each status returned.
  # 
  # Example:
  #  twitter.timeline_for(:public) do |status|
  #    puts status.user.screen_name, status.text
  #  end
  #  
  #  twitter.timeline_for(:friend, :id => 'myfriend', :since => 30.minutes.ago) do |status|
  #    puts status.user.screen_name, status.text
  #  end
  #  
  #  timeline = twitter.timeline_for(:me) do |status|
  #    puts status.text
  #  end
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>type</tt> 
  # is given.  Valid types are:
  # * +:public+
  # * +:friends+
  # * +:friend+
  # * +:user+
  # * +:me+
  def timeline_for(type, options = {}, &block)
    raise ArgumentError, "Invalid timeline type: #{type}" unless @@TIMELINE_URIS.keys.member?(type)
    uri = @@TIMELINE_URIS[type]
    response = http_connect {|conn| create_http_get_request(uri, options) }
    timeline = Twitter::Status.unmarshal(response.body)
    timeline.each {|status| bless_model(status); yield status if block_given? }
    timeline
  end
end
