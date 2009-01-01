# 
require('rubygems')

module Twitter; end

def require_local(suffix)
  require(File.expand_path(File.join(File.dirname(__FILE__), suffix)))
end

# For better unicode support
$KCODE = 'u'
require 'jcode'

# External requires
require('yaml')
require('date')
require('time')
require('net/https')
require('uri')
require('cgi')
require('json')
require('yaml')

# Ordering matters...pay attention here!
require_local('twitter/ext')
require_local('twitter/version')
require_local('twitter/meta')
require_local('twitter/core')
require_local('twitter/model')
require_local('twitter/config')
require_local('twitter/client')
require_local('twitter/console')
