$:.unshift('lib')

require('rubygems')
gem('rspec')

ROOT_DIR = File.join(File.dirname(__FILE__))

require('rake')
require('twitter')

import('tasks/clean.rake')
import('tasks/doc.rake')
import('tasks/find.rake')
import('tasks/metrics.rake')
import('tasks/pkg.rake')
import('tasks/rubyforge.rake')
import('tasks/spec.rake')
import('tasks/stats.rake')
import('tasks/web.rake')

task :default => [:coverage]

namespace :spec do
  task :autotest do
    Autotest::Rspec.run
  end
end
