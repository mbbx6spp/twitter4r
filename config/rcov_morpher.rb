
require('erb')
require('tidy')
require('hpricot')

class File #:nodoc:
  class << self
    # Reads in local file from current directory.
    def read_local(file)
      self.read(self.join(self.dirname(__FILE__), file))
    end
  end
end

# Follows <tt>Strategy</tt> design pattern
class RCovMorpher
  # transforms given list of <tt>files</tt> based on new template.
  def transform(files, output_dir = '../web/rcov/', template = 'templates/rcov.rhtml')
    files.each do |file|
      data = File.read(file)
      fname = File.basename(file)
      xml = Tidy.open(:show_warnings => true) do |tidy|
        tidy.options.output_xml = true
        tidy.clean(data)
      end
      
      rhtml = ERB.new(File.read_local(template), 0)
      parser = Hpricot.parse(xml)
      legend_content = parser.find_element('pre')
      table_content = parser.find_element('table')
      code_content = table_content.next_sibling
      index = (fname == 'index.html')
      File.delete(fname) if File.exists?(fname)
      File.open("#{output_dir}/#{fname}", 'w') do |f|
        f.puts(rhtml.result(binding))
      end
    end
  end
end

if __FILE__ == $0
  overrides = YAML.load(File.read_local('tidy.yml'))
  Tidy.path = overrides['path'] || '/usr/lib/libtidy-0.99.so.0'
  html_files = Dir.glob(overrides['html_glob'] || 'doc/rcov/**/*.html')

  morpher = RCovMorpher.new
  morpher.transform(html_files)
end
