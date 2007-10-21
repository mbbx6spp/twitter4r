require File.dirname(__FILE__) + '/../../spec_helper.rb'

module Spec
  module Mocks
    describe "using a Partial Mock," do
      before(:each) do
        @object = Object.new
      end
      
      it "should_not_receive should mock out the method" do
        @object.should_not_receive(:fuhbar)
        @object.fuhbar
        lambda do
          @object.rspec_verify
        end.should raise_error(Spec::Mocks::MockExpectationError)
      end

      it "should_not_receive should return a negative message expectation" do
        @object.should_not_receive(:foobar).should be_kind_of(NegativeMessageExpectation)
      end

      it "should_receive should mock out the method" do
        @object.should_receive(:foobar).with(:test_param).and_return(1)
        @object.foobar(:test_param).should equal(1)
      end

      it "should_receive should handle a hash" do
        @object.should_receive(:foobar).with(:key => "value").and_return(1)
        @object.foobar(:key => "value").should equal(1)
      end

      it "should_receive should handle an inner hash" do
        hash = {:a => {:key => "value"}}
        @object.should_receive(:foobar).with(:key => "value").and_return(1)
        @object.foobar(hash[:a]).should equal(1)
      end

      it "should_receive should return a message expectation" do
        @object.should_receive(:foobar).should be_kind_of(MessageExpectation)
        @object.foobar
      end

      it "should_receive should verify method was called" do
        @object.should_receive(:foobar).with(:test_param).and_return(1)
        lambda do
          @object.rspec_verify
        end.should raise_error(Spec::Mocks::MockExpectationError)
      end

    end
  end
end
