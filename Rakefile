$:.unshift('lib')

require('rubygems')
gem('rspec', '>=1.0.0')

require('rake')
require('twitter')

import('tasks/clean.rake')
import('tasks/doc.rake')
import('tasks/pkg.rake')
import('tasks/rubyforge.rake')
import('tasks/spec.rake')
import('tasks/todo.rake')
import('tasks/web.rake')

task :default => [:coverage]

namespace :spec do
  task :autotest do
    Autotest::Rspec.run
  end
end
