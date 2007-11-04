require File.join(File.dirname(__FILE__), '..', 'spec_helper')

def glob_files(*path_elements)
  Dir.glob(File.join(*path_elements))
end

def load_erb_yaml(path, context)
  ryaml = ERB.new(File.read(path), 0)
  YAML.load(ryaml.result(context))
end

module ERBMetaMixin
  # Needed to make the YAML load work...
  def project_files
    glob_files(@root_dir, 'lib', '**/*.rb')
  end

  # Needed to make the YAML load work...
  def spec_files
    glob_files(@root_dir, 'spec', '**/*_spec.rb')
  end
end

describe "Twitter::Meta cache policy" do
  include ERBMetaMixin
  before(:each) do
    @root_dir = project_root_dir
    @meta = Twitter::Meta.new(@root_dir)
    @expected_pkg_info = load_erb_yaml(File.join(@root_dir, 'pkg-info.yml'), binding)
    @expected_project_files = project_files
    @expected_spec_files = spec_files
  end
  
  it "should store value returned from project_files in @project_files after first glob" do
    @meta.instance_eval("@project_files").should eql(nil)
    @meta.project_files
    @meta.instance_eval("@project_files").should eql(@expected_project_files)
    @meta.project_files
    @meta.instance_eval("@project_files").should eql(@expected_project_files)
  end
  
  it "should store value returned from spec_files in @spec_files after first glob" do
    @meta.instance_eval("@spec_files").should eql(nil)
    @meta.spec_files
    @meta.instance_eval("@spec_files").should eql(@expected_spec_files)
    @meta.spec_files
    @meta.instance_eval("@spec_files").should eql(@expected_spec_files)
  end
end

describe "Twitter::Meta" do
  include ERBMetaMixin
  before(:each) do
    @root_dir = project_root_dir
    @meta = Twitter::Meta.new(@root_dir)
    @expected_yaml_hash = load_erb_yaml(File.join(@root_dir, 'pkg-info.yml'), binding)
    @expected_project_files = project_files
    @expected_spec_files = spec_files
  end
  
  it "should load and return YAML file into Hash object upon #pkg_info call" do
    yaml_hash = @meta.pkg_info
    yaml_hash.should.eql? @expected_yaml_hash
  end
  
  it "should return the embedded hash responding to key 'spec' of #pkg_info call upon #spec_info call" do
    yaml_hash = @meta.spec_info
    yaml_hash.should.eql? @expected_yaml_hash['spec']
  end
  
  it "should return list of files matching ROOT_DIR/lib/**/*.rb upon #project_files call" do
    project_files = @meta.project_files
    project_files.should.eql? @expected_project_files
  end
  
  it "should return list of files matching ROOT_DIR/spec/**/*.rb upon #spec_files call" do
    spec_files = @meta.spec_files
    spec_files.should.eql? @expected_spec_files    
  end
  
  it "should return Gem specification based on YAML file contents and #project_files and #spec_files return values" do
    spec = @meta.gem_spec
    expected_spec_hash = @expected_yaml_hash['spec']
    expected_spec_hash.each do |key, val|
      unless val.is_a?(Hash)
        spec.send(key).should.eql? expected_spec_hash[key]
      end
    end
  end
end
