# = Status API Examples
#  require('rubygems')
#  gem('twitter4r', '0.2.0')
#  require('twitter')
# 
# The following is only required if you want to use some configuration 
# helper methods like <tt>Twitte4R::Client.from_config</tt> for 
# sensitive/instance context.
#  require 'twitter/console'
#  config_file = File.join(File.dirname(__FILE__), '..', 'config', 'twitter.yml')
#  
# To override client connection configuration please refer to 
# the {<tt>configure.rb</tt>}[file:configure_rb.html] example code.
#  twitter = Twitter::Client.from_config(config_file)
# 
# To post a new status we can do:
#  status = twitter.status(:post, 'NOT buying overrated iPhone.')
# 
# To retrieve the status from it's unique integer status ID we can do the 
# following:
#  status = twitter.status(:get, status.id)
# 
# To delete a status message we can do:
#  twitter.status(:delete, status)
