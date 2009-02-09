class Twitter::Client
  @@GRAPH_URIS = {
    :friends => '/friends/ids',
    :followers => '/followers/ids',
  }
	
  # Provides access to the Twitter Social Graphing API.
  # 
  # You can retrieve the full graph of a user's friends or followers in one method call.
  # 
  # <tt>action</tt> can be any of the following values:
  # * <tt>:friends</tt> - retrieves ids of all friends of a given user.
  # * <tt>:followers</tt> - retrieves ids of all followers of a given user.
  # 
  # The <tt>value</tt> must be either the user screen name, integer unique user ID or Twitter::User 
  # object representation.
  # 
  # Examples:
  #  screen_name = 'dictionary'
  #  client.graph(:friends, 'dictionary')
  #  client.graph(:followers, 'dictionary')
  #  id = 1260061
  #  client.graph(:friends, id)
  #  client.graph(:followers, id)
  #  user = Twitter::User.find(id, client)
  #  client.graph(:friends, user)
  #  client.graph(:followers, user)
  def graph(action, value = nil)
    raise ArgumentError, "Invalid friend action provided: #{action}" unless @@GRAPH_URIS.keys.member?(action)
    id = value.to_i unless value.nil? || value.is_a?(String)
    id ||= value
    id ||= @login
    uri = "#{@@GRAPH_URIS[action]}.json"
    response = http_connect {|conn| create_http_get_request(uri, :id => id) }
    JSON.parse(response.body)
  end
end
