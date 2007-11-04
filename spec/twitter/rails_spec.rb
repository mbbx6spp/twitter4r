require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe String, "representing a class name" do

  before(:each) do
    @class_name = Twitter::User.class.name
    @xmlized_name = @class_name.downcase # simple case for the moment...since Rails' support for namespaced models sucks!
  end

  it "should be downcased (minus module namespaces) when xmlized" do
    @class_name.xmlize.should eql(@xmlized_name)
  end

  after(:each) do
    nilize(@class_name, @xmlized_name)
  end  
end

describe "Rails model extensions for model classes", :shared => true do

  before(:each) do
    @id = 3242334
    @id_s = @id.to_s
    @model = model(@id)
    @model_hash = @model.to_hash
    @json = JSON.unparse(@model_hash)
    @serializer = ActiveRecord::XmlSerializer.new(@model, {:root => @model.class.name.downcase})
    @xml = @serializer.to_s
  end

  it "should invoke #to_param as expected" do
    @model.should_receive(:id).and_return(@id)
    @model.to_param
  end
  
  it "should return string representation for id for #to_param" do
    @model.to_param.class.should eql(String)
  end
  
  it "should return output from JSON.unparse for #to_json" do
    @model.should_receive(:to_hash).and_return(@model_hash)
    JSON.should_receive(:unparse).and_return(@json)
    @model.to_json
  end
  
  it "should return XmlSerializer string output for #to_xml" do
    ActiveRecord::XmlSerializer.should_receive(:new).and_return(@serializer)
    @serializer.should_receive(:to_s).and_return(@xml)
    @model.to_xml
  end
  
  after(:each) do
    nilize(@id, @model)
  end
end

describe Twitter::User, "Rails extensions" do

  def model(id)
    Twitter::User.new(:id => id)
  end

  it_should_behave_like "Rails model extensions for model classes"
end

describe Twitter::Status, "Rails extensions" do

  def model(id)
    Twitter::Status.new(:id => id)
  end

  it_should_behave_like "Rails model extensions for model classes"
end

describe Twitter::Message, "Rails extensions" do

  def model(id)
    Twitter::Message.new(:id => id)
  end

  it_should_behave_like "Rails model extensions for model classes"
end

describe Twitter::RESTError, "Rails extensions" do
  
  before(:each) do
    @attributes = { :code => 200, :message => 'Success', :uri => 'http://twitter.com/statuses' }
    @model = Twitter::RESTError.new(@attributes)
    @json = "JSON" # doesn't really matter what the value is
  end
  
  it "should return a Hash of attribute name-value pairs for #to_hash" do
    @model.to_hash.should === @attributes
  end

  it "should invoke XmlSerializer for #to_xml" do
    
    @model.to_xml
  end

  it "should return expected JSON for #to_json" do
    @model.to_hash
    JSON.should_receive(:unparse).and_return(@json)
    @model.to_json
  end

  after(:each) do
    nilize(@attributes, @model)
  end  
end
