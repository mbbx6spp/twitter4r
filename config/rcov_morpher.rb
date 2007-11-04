module RCov; end

require('erb')
require('tidy')
require('hpricot')

require(File.join(File.dirname(__FILE__), '..', 'lib', 'twitter'))

class File #:nodoc:
  class << self
    # Reads in local file from current directory.
    def read_local(file)
      self.read(self.join(self.dirname(__FILE__), file))
    end
  end
end

# Follows <tt>Strategy</tt> design pattern
class RCov::OutputMorpher
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
      version = Twitter::Version.to_version
      File.delete(fname) if File.exists?(fname)
      File.open("#{output_dir}/#{fname}", 'w') do |f|
        f.puts(rhtml.result(binding))
      end
    end
  end
end

module RCov
  class << self
    # returns html files to morph based on tidy configuration file
    def configure_morpher(tidy_conf = 'tidy.yml')
      overrides = YAML.load(File.read_local('tidy.yml'))
      Tidy.path = overrides['path'] || '/usr/lib/libtidy-0.99.so.0'
      Dir.glob(overrides['html_glob'] || 'doc/rcov/**/*.html')      
    end
  end
end

if __FILE__ == $0
  RCov::OutputMorpher.new.transform(RCov.configure_morpher)
end
