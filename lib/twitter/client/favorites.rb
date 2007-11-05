class Twitter::Client
  # Why Twitter.com developers can't correctly document their API, I do not know!
	@@FAVORITES_URIS = {
		:add => '/favourings/create',
		:remove => '/favourings/destroy',
	}

  # Provides access to the Twitter list favorites API.
  # 
  # You can access the authenticated [Twitter] user's favorites list using this method.
  # 
  # By default you will receive the last twenty statuses added to your favorites list.
  # To get a previous page you can provide options to this method.  For example,
  #  statuses = client.favorites(:page => 2)
  # The above one-liner will get the second page of favorites for the authenticated user.
	def favorites(options = nil)
	  def uri_suffix(opts); opts && opts[:page] ? "?page=#{opts[:page]}" : ""; end
    uri = '/favorites.json' + uri_suffix(options)
    response = http_connect {|conn|	create_http_get_request(uri) }
    bless_models(Twitter::Status.unmarshal(response.body))
	end
	
	# Provides access to the Twitter add/remove favorite API.
	# 
	# You can add and remove favorite status using this method.
	# 
	# <tt>action</tt> can be any of the following values:
	# * <tt>:add</tt> - to add a status to your favorites, you would use this <tt>action</tt> value
	# * <tt>:remove</tt> - to remove an status from your existing favorites list use this.
	# 
	# The <tt>value</tt> must be either the status object to add or remove or 
	# the integer unique status ID.
	# 
	# Examples:
	#  id = 126006103423
	#  client.favorite(:add, id)
	#  client.favorite(:remove, id)
	#  status = Twitter::Status.find(id, client)
	#  client.favorite(:add, status)
	#  client.favorite(:remove, status)
	def favorite(action, value)
	  raise ArgumentError, "Invalid favorite action provided: #{action}" unless @@FAVORITES_URIS.keys.member?(action)
		value = value.to_i.to_s unless value.is_a?(String)
		uri = "#{@@FAVORITES_URIS[action]}/#{value}.json"
		case action
		when :add
		  response = http_connect {|conn| create_http_post_request(uri) }
		when :remove
		  response = http_connect {|conn| create_http_delete_request(uri) }
		end
		bless_model(Twitter::Status.unmarshal(response.body))
	end
end
