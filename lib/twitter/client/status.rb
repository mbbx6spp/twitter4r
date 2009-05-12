class Twitter::Client
  @@STATUS_URIS = {
  	:get => '/statuses/show.json',
  	:post => '/statuses/update.json',
  	:delete => '/statuses/destroy.json',
  	:reply => '/statuses/update.json',
  }
  
  # Provides access to individual statuses via Twitter's Status APIs
  # 
  # <tt>action</tt> can be of the following values:
  # * <tt>:get</tt> to retrieve status content.  Assumes <tt>value</tt> given responds to :to_i message in meaningful way to yield intended status id.
  # * <tt>:post</tt> to publish a new status
  # * <tt>:delete</tt> to remove an existing status.  Assumes <tt>value</tt> given responds to :to_i message in meaningful way to yield intended status id.
  # * <tt>:reply</tt> to reply to an existing status.  Assumes <tt>value</tt> given is <tt>Hash</tt> which contains <tt>:in_reply_to_status_id</tt> and <tt>:status</tt>
  # 
  # <tt>value</tt> should be set to:
  # * the status identifier for <tt>:get</tt> case
  # * the status text message for <tt>:post</tt> case
  # * none necessary for <tt>:delete</tt> case
  # 
  # Examples:
  #  twitter.status(:get, 107786772)
  #  twitter.status(:post, "New Ruby open source project Twitter4R version 0.2.0 released.")
  #  twitter.status(:delete, 107790712)
  # 
  # An <tt>ArgumentError</tt> will be raised if an invalid <tt>action</tt> 
  # is given.  Valid actions are:
  # * +:get+
  # * +:post+
  # * +:delete+
  def status(action, value = nil)
    return self.timeline_for(action, value || {}) if :replies == action
    raise ArgumentError, "Invalid status action: #{action}" unless @@STATUS_URIS.keys.member?(action)
    return nil unless value
    uri = @@STATUS_URIS[action]
    response = nil
    case action
    when :get
    	response = http_connect {|conn|	create_http_get_request(uri, :id => value.to_i) }
    when :post
    	response = http_connect({:status => value, :source => @@config.source}.to_http_str) {|conn| create_http_post_request(uri) }
    when :delete
    	response = http_connect {|conn| create_http_delete_request(uri, :id => value.to_i) }
    when :reply
      return nil if (!value.is_a?(Hash) || !value[:status] || !value[:in_reply_to_status_id])
      response = http_connect(value.merge(:source => @@config.source).to_http_str) {|conn| create_http_post_request(uri) }
    end
    bless_model(Twitter::Status.unmarshal(response.body))
  end
end
