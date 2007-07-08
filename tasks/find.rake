
def egrep(pattern)
  Dir.glob('**/*.rb').each do |name|
    count = 0
    open(name) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{name}:#{count}:#{line}"
        end
      end
    end
  end
end

namespace :find do
  desc "Find TODO tags in the code"
  task :todos do
    egrep /(TODO)/
  end

  desc "Find FIXME tags in the code"
  task :fixmes do
    egrep /(FIXME)/
  end

  desc "Find TBD tags in the code"
  task :tbds do
    egrep /(TBD)/
  end
end
