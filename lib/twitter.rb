module Twitter; end

def resolve_path(suffix)
  File.expand_path(File.join(File.dirname(__FILE__), suffix))
end

# For better unicode support
$KCODE = 'u'
require 'jcode'

# Ordering matters...pay attention here!
require(resolve_path('twitter/version'))
require(resolve_path('twitter/meta'))
require(resolve_path('twitter/core'))
