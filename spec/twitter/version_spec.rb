require File.join(File.dirname(__FILE__), '..', 'spec_helper')

VERSION_LIST = [Twitter::Version::MAJOR, Twitter::Version::MINOR, Twitter::Version::REVISION]

EXPECTED_VERSION = VERSION_LIST.join('.')
EXPECTED_NAME = VERSION_LIST.join('_')

describe Twitter::Version, ".to_version" do
  it "should return #{EXPECTED_VERSION}" do
    Twitter::Version.to_version.should eql(EXPECTED_VERSION)
  end
end

describe Twitter::Version, ".to_name" do
  it "should return #{EXPECTED_NAME}" do
    Twitter::Version.to_name.should eql(EXPECTED_NAME)
  end
end

