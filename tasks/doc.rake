require 'rake/rdoctask'

desc 'Generate RDoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title = "Twitter4R v#{Twitter::Version.to_version}: Open Source Ruby Client Library for the Twitter REST API"
  rdoc.template = 'config/rdoc_template.rb'
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README' << '--line-numbers'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('CHANGES')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('examples/**/*.rb')
end
