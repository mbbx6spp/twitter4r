require File.join(File.dirname(__FILE__), '..', 'spec_helper')

VERSION_LIST = [Twitter::Version::MAJOR, Twitter::Version::MINOR, Twitter::Version::REVISION]

EXPECTED_VERSION = VERSION_LIST.join('.')
EXPECTED_NAME = VERSION_LIST.join('_')

context "Twitter::Version.to_version" do
  specify "should return #{EXPECTED_VERSION}" do
    Twitter::Version.to_version.should.eql EXPECTED_VERSION
  end
end

context "Twitter::Version.to_name" do
  specify "should return #{EXPECTED_NAME}" do
    Twitter::Version.to_name.should.eql EXPECTED_NAME
  end
end

