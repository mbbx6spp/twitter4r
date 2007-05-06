$:.unshift('lib')

require('rubygems')
require('rake')
require('twitter')

import('tasks/clean.rake')
import('tasks/doc.rake')
import('tasks/pkg.rake')
import('tasks/rubyforge.rake')
import('tasks/spec.rake')
import('tasks/web.rake')

task :default => [:coverage]
