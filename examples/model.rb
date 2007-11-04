# = Model API Examples
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
# The purpose of the <b>Model API</b> is to make Twitter REST methods 
# integrated into class and instance methods that resemble 
# <tt>ActiveRecord</tt> class API.
# 
# == Create Methods
# For example, suppose we want to create a new direct message to a friend:
#  message = Twitter::Message.create(
#    :text => 'Ich liebe dich!',
#    :client => twitter,
#    :recipient => 'myspouse')
# 
# We can also create a new status message, which updates our (the 
# authenticated user's) timeline:
#  status = Twitter::Status.create(
#    :text => 'Doing early Christmas shopping in July',
#    :client => twitter)
# 
# Notice we must always pass in a <tt>:client</tt> key-value pair giving
# the client context object.
# 
# There is currently no useful Twitter::User.create implementation as 
# <tt>Twitter</tt> does not provide this server REST API.  This is *not* 
# a <tt>Twitter4R</tt> limitation.  Please harass the Twitter.com/Obvious 
# developer for this not me please.
# 
# == Finder Methods
# We can also use finder methods that look very similar to 
# <tt>ActiveRecord</tt> style classes:
#  user = Twitter::User.find('myfriend', twitter)
#  status = Twitter::Status.find(status.id, twitter)
# 
# There is currently no useful Twitter::Message.find implementation as 
# <tt>Twitter</tt> does not provide this server REST API.  Ths is *not* 
# a <tt>Twitter4R</tt> limitation.  Please harass the Twitter.com/Obvious 
# developer for this not me please.
# 
# == Domain Specific Methods
# <tt>Twitter::User</tt> has a few domain specific methods for convenience:
#  user.is_me? # => false since <tt>user</tt> is 'myfriend' not authenticated user
#  me = Twitter::User.find('mylogin')
#  me.is_me? # => true since <tt>me</tt> is authenticated user
#  me.followers # => return Array of followers for authenticated user (only available for authenticated user)
#  me.friends # => returns Array of friends for that user instance
#  me.befriend(user) # => user (only available for authenticated user)
#  me.defriend(user) # => user (only available for authenticated user)
