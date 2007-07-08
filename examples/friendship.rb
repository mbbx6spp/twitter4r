# = Friendship API Examples
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
# To add a friend to the authenticated user's list of friends using the 
# client context object you can do:
#  twitter.friend(:add, 'otherlogin')
# You may also pass in the unique integer user ID or the Twitter::User object
# representation of the user you wish to 'friend'.  For example:
#  user = twitter.user('otherlogin')
#  twitter.friend(:add, user)
# OR
#  twitter.friend(:add, user.id)
# 
# To remove a friend from the authenticated user's list of friends using the 
# client context object you can do:
#  twitter.friend(:remove, 'otherlogin')
# As with the case of adding a new friend, you can use the unique integer user 
# ID or the Twitter::User object representation of the user you wish to remove
# as a friend.  See above "add" examples and replace ":add" with ":remove" for 
# desired effect.
