require 'rake/rdoctask'

desc 'Generate RDoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title = 'Twitter4R'
  rdoc.template = 'config/rdoc_template.rb'
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README' << '--line-numbers'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('CHANGES')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('examples/**/*.rb')
end
