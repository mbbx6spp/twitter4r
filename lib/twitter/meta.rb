# meta.rb contains <tt>Twitter::Meta</tt> and related classes that
# help define the metadata of the <tt>Twitter4R</tt> project.

require('rubygems')
require('erb')

class Twitter::Meta #:nodoc:
  attr_accessor :root_dir
  attr_reader :gem_spec, :project_files, :spec_files

  # Initializer for Twitter::Meta class.  Takes <tt>root_dir</tt> as parameter.
  def initialize(root_dir)
    @root_dir = root_dir
  end

  # Returns package information defined in <tt>root_dir</tt>/pkg-info.yml
  def pkg_info
    yaml_file = File.join(@root_dir, 'pkg-info.yml')
    ryaml = ERB.new(File.read(yaml_file), 0)
    s = ryaml.result(binding)
    YAML.load(s)
  end
  
  # Returns RubyGems spec information
  def spec_info
    self.pkg_info['spec'] if self.pkg_info
  end
  
  # Returns list of project files
  def project_files
    @project_files ||= Dir.glob(File.join(@root_dir, 'lib/**/*.rb'))
    @project_files
  end
  
  # Returns list of specification files
  def spec_files
    @spec_files ||= Dir.glob(File.join(@root_dir, 'spec/**/*_spec.rb'))
    @spec_files
  end
  
  # Returns RubyGem specification for Twitter4R project
  def gem_spec
    @gem_spec ||= Gem::Specification.new do |spec|
      self.spec_info.each do |key, val|
        if val.is_a?(Hash)
          val.each do |k, v|
            spec.send(key, k, v)
          end
        else
          spec.send("#{key}=", val)
        end
      end
    end
    @gem_spec
  end
end
