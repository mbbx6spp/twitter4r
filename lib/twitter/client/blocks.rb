class Twitter::Client
  @@BLOCK_URIS = {
    :add => '/blocks/create',
    :remove => '/blocks/destroy',
  }
	
  # Provides access to the Twitter Block API.
  # 
  # You can add and remove blocks to users using this method.
  # 
  # <tt>action</tt> can be any of the following values:
  # * <tt>:add</tt> - to add a block, you would use this <tt>action</tt> value
  # * <tt>:remove</tt> - to remove a block use this.
  # 
  # The <tt>value</tt> must be either the user screen name, integer unique user ID or Twitter::User 
  # object representation.
  # 
  # Examples:
  #  screen_name = 'dictionary'
  #  client.block(:add, 'dictionary')
  #  client.block(:remove, 'dictionary')
  #  id = 1260061
  #  client.block(:add, id)
  #  client.block(:remove, id)
  #  user = Twitter::User.find(id, client)
  #  client.block(:add, user)
  #  client.block(:remove, user)
  def block(action, value)
    raise ArgumentError, "Invalid friend action provided: #{action}" unless @@BLOCK_URIS.keys.member?(action)
    value = value.to_i unless value.is_a?(String)
    uri = "#{@@BLOCK_URIS[action]}/#{value}.json"
    response = http_connect {|conn| create_http_get_request(uri) }
    bless_model(Twitter::User.unmarshal(response.body))
  end
end
