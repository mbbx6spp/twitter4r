class Twitter::Client

  @@MESSAGING_URIS = {
    :received => '/direct_messages.json',
    :sent => '/direct_messages/sent.json',
    :post => '/direct_messages/new.json',
    :delete => '/direct_messages/destroy',
  }

  # Provides access to Twitter's Messaging API for received and 
  # sent direct messages.
  # 
  # Example:
  #  received_messages = @twitter.messages(:received)
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:received+
  # * +:sent+
  def messages(action)
    raise ArgumentError, "Invalid messaging action: #{action}" unless [:sent, :received].member?(action)
    uri = @@MESSAGING_URIS[action]
  	response = http_connect {|conn|	create_http_get_request(uri) }
  	bless_models(Twitter::Message.unmarshal(response.body))
  end
  
  # Provides access to Twitter's Messaging API for sending and deleting 
  # direct messages to other users.
  # 
  # <tt>action</tt> can be:
  # * <tt>:post</tt> - to send a new direct message, <tt>value</tt>, to <tt>user</tt> given.
  # * <tt>:delete</tt> - to delete direct message with message ID <tt>value</tt>.
  # 
  # <tt>value</tt> should be:
  # * <tt>String</tt> when action is <tt>:post</tt>.  Will be the message text sent to given <tt>user</tt>.
  # * <tt>Integer</tt> or <tt>Twitter::Message</tt> object when action is <tt>:delete</tt>.  Will refer to the unique message ID to delete.  When passing in an instance of <tt>Twitter::Message</tt> that Status will be 
  # 
  # <tt>user</tt> should be:
  # * <tt>Twitter::User</tt> or <tt>Integer</tt> object when <tt>action</tt> is <tt>:post</tt>.
  # * totally ignore when <tt>action</tt> is <tt>:delete</tt>.  It has no purpose in this use case scenario.
  # 
  # Examples:
  # The example below sends the message text 'Are you coming over at 6pm for the BBQ tonight?' to user with screen name 'myfriendslogin'...
  #  @twitter.message(:post, 'Are you coming over at 6pm for the BBQ tonight?', 'myfriendslogin')
  # The example below sends the same message text as above to user with unique integer ID of 1234567890...
  # the example below sends the same message text as above to user represented by <tt>user</tt> object instance of <tt>Twitter::User</tt>...
  #  @twitter.message(:post, 'Are you coming over at 6pm for the BBQ tonight?', user)
  #  message = @twitter.message(:post, 'Are you coming over at 6pm for the BBQ tonight?', 1234567890)
  # the example below delete's the message send directly above to user with unique ID 1234567890...
  #  @twitter.message(:delete, message)
  # Or the following can also be done...
  #  @twitter.message(:delete, message.id)
  # 
  # In both scenarios (<tt>action</tt> is <tt>:post</tt> or 
  # <tt>:delete</tt>) a blessed <tt>Twitter::Message</tt> object is 
  # returned that represents the newly posted or newly deleted message.
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:post+
  # * +:delete+
  def message(action, value, user = nil)
    raise ArgumentError, "Invalid messaging action: #{action}" unless [:post, :delete].member?(action)
    uri = @@MESSAGING_URIS[action]
    case action
    when :post
      response = http_connect({:text => value, :user => user.to_i}.to_http_str) {|conn| create_http_post_request(uri) }
    when :delete
      response = http_connect {|conn| create_http_delete_request(uri, :id => value.to_i) }
    end
    message = Twitter::Message.unmarshal(response.body)
    bless_model(message)
  end
end
