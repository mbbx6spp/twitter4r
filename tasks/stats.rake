require('code_statistics')

class CodeStatistics
  TEST_TYPES = %w(Specs)

  def to_embedded_html
    output = "<table id=\"stats\">\n"
    output << "\t<th><td>Name</td><td>Lines</td><td>LOC</td><td>Classes</td><td>Methods</td><td>M/C</td><td>LOC/M</td></th>\n"
    @pairs.each { |p| output << html_row(p) }
    output << "</table>"
    output
  end

  private
    def html_row(pair)
      stats = @statistics[pair.first]
      methods = stats["methods"]
      classes = stats["classes"]
      loc = stats["codelines"]
      lines = stats["lines"]
      mpc = methods/classes
      lpm = loc/methods
      
      "\t<tr><td>#{pair.first}</td><td>#{lines}</td><td>#{loc}</td><td>#{classes}</td><td>#{methods}</td><td>#{mpc}</td><td>#{lpm}</td></tr>\n"
    end
end

namespace :stats do
  STATS_DIRECTORIES = [
    %w(Library\ Code   lib),
    %w(Specs        spec)
  ].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

  desc "Report code statistics (KLOCs, etc) for code"
  task :default do
    verbose = true
    CodeStatistics.new(*STATS_DIRECTORIES).to_s
  end

  desc "Report code statistics (KLOCs, etc) for code in HTML"
  task :html do
    puts CodeStatistics.new(*STATS_DIRECTORIES).to_embedded_html
  end
end

