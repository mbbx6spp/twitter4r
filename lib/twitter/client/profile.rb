class Twitter::Client
  @@PROFILE_URIS = {
    :info => '/account/update_profile',
    :colors => '/account/update_profile_colors',
    :device => '/account/update_delivery_device',
  }
  
  # Provides access to the Twitter Profile API.
  # 
  # You can update profile information.  You can update the types of profile 
  # information:
  # * :info (name, email, url, location, description)
  # * :colors (background_color, text_color, link_color, sidebar_fill_color, 
  # sidebar_border_color)
  # * :device (set device to either "sms", "im" or "none")
  # 
  # Example:
  #  user = client.profile(:info, :location => "University Library")
  #  puts user.inspect
  def profile(action, attributes)
    connection = create_http_connection
    connection.start do |connection|
      response = http_connect(attributes.to_http_str) do |conn|
        create_http_post_request(@@PROFILE_URIS[action])
      end
      bless_models(Twitter::User.unmarshal(response.body))
    end
  end
end
