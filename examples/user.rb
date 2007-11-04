# = User API Examples
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
# To get the Twitter::User object representation of a Twitter user we can do:
#  user = twitter.user('otherlogin')
# 
# To get a list of friends of a specific user on Twitter we can do:
#  friends = twitter.user('otherlogin', :friends)
# See the {Model API}[link:files/examples/model_rb.html] for related methods.
# 
# To get the authenticated user's Twitter::User object representation we can 
# do:
#  me = twitter.my(:info)
# 
# To get the authenticated user's followers (only available for authenticated 
# user):
#  followers = twitter.my(:followers)
# OR 
#  myuser = twitter.my(:info)
#  followers = myuser.followers
# See the {Model API}[link:files/examples/model_rb.html] for more information 
# on this.
