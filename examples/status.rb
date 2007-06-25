# = Status API Examples
#  require('rubygems')
#  gem('twitter4r', '0.2.0')
#  require('twitter')
# 
# only required if you want to use some configuration helper methods like 
# <tt>Twitte4R::Client.from_config</tt> for sensitive/instance context.
# 
#  require 'twitter/console'
#  config_file = File.join(File.dirname(__FILE__), '..', 'config', 'twitter.yml')
# 
# Not configuring <tt>Twitter::Client</tt> for global features such as overriding:
# * protocol
# * host
# * port
# * user agent
# * proxy information
# Since the defaults are satisfactory, but if you need to, please refer to 
# the {<tt>configure.rb</tt>}[file:configure_rb.html] example code.
# 
#  twitter = Twitter::Client.from_config(config_file)
# 
# 
