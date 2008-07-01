ROOT_DIR = File.dirname(__FILE__)
require(File.join(ROOT_DIR, 'lib', 'twitter', 'meta'))

meta = Twitter::Meta.new(File.join(ROOT_DIR))
meta.gem_spec

