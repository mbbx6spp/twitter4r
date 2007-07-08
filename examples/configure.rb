# = Configuration API Examples
#  require('rubygems')
#  gem('twitter4r', '0.2.0')
#  require('twitter')
# 
# Here we setup configuration for all Twitter::Client instances
# This looks much like Rails' Initializer code that can be found 
# in config/environment in Rails applications by design.
#  Twitter::Client.configure do |conf|
#    # We can set Twitter4R to use <tt>:ssl</tt> or <tt>:http</tt> to connect to the Twitter API.
#    # Defaults to <tt>:ssl</tt>
#    conf.protocol = :ssl
#
#    # We can set Twitter4R to use another host name (perhaps for internal
#    # testing purposes).
#    # Defaults to 'twitter.com'
#    conf.host = 'twitter.com'
#
#    # We can set Twitter4R to use another port (also for internal 
#    # testing purposes).
#    # Defaults to 443
#    conf.port = 443
#    
#    # We can set proxy information for Twitter4R
#    # By default all following values are set to <tt>nil<tt>.
#    conf.proxy_host = 'myproxy.host'
#    conf.proxy_port = 8080
#    conf.proxy_user = 'myuser'
#    conf.proxy_pass = 'mypass'
#
#    # We can also change the User-Agent and X-Twitter-Client* HTTP headers
#    conf.user_agent = 'MyAppAgentName'
#    conf.application_name = 'MyAppName'
#    conf.application_version = 'v1.5.6'
#    conf.application_url = 'http://myapp.url'
#  end
