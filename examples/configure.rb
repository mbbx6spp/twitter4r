require 'twitter'

# Here we setup configuration for all Twitter::Client instances
# This looks much like Rails' Initializer code that can be found 
# in config/environment in Rails applications by design.
Twitter::Client.configure do |conf|
  # We can set Twitter4R to use <tt>:ssl</tt> or <tt>:http</tt> to connect to the Twitter API.
  # Defaults to <tt>:ssl</tt>
  conf.protocol = :ssl

  # We can set Twitter4R to use another host name (perhaps for internal
  # testing purposes).
  # Defaults to 'twitter.com'
  conf.host = 'twitter.com'

  # We can set Twitter4R to use another port (also for internal 
  # testing purposes).
  # Defaults to 443
  conf.port = 443
end
