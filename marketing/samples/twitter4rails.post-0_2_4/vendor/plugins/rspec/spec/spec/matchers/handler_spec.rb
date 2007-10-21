require File.dirname(__FILE__) + '/../../spec_helper.rb'

module ExampleExpectations
  
  class ArbitraryMatcher
    def initialize(*args, &block)
      if args.last.is_a? Hash
        @expected = args.last[:expected]
      end
      if block_given?
        @expected = block.call
      end
      @block = block
    end
    
    def matches?(target)
      @target = target
      return @expected == target
    end
    
    def with(new_value)
      @expected = new_value
      self
    end
    
    def failure_message
      "expected #{@expected}, got #{@target}"
    end
    
    def negative_failure_message
      "expected not #{@expected}, got #{@target}"
    end
  end
  
  class PositiveOnlyMatcher < ArbitraryMatcher
    undef negative_failure_message
  end
  
  def arbitrary_matcher(*args, &block)
    ArbitraryMatcher.new(*args, &block)
  end
  
  def positive_only_matcher(*args, &block)
    PositiveOnlyMatcher.new(*args, &block)
  end
  
end

module Spec
  module Expectations
    describe ExpectationMatcherHandler, ".handle_matcher" do
      it "should ask the matcher if it matches" do
        matcher = mock("matcher")
        actual = Object.new
        matcher.should_receive(:matches?).with(actual).and_return(true)
        ExpectationMatcherHandler.handle_matcher(actual, matcher)
      end
    end
    
    describe ExpectationMatcherHandler do
      include ExampleExpectations
      
      it "should handle submitted args" do
        5.should arbitrary_matcher(:expected => 5)
        5.should arbitrary_matcher(:expected => "wrong").with(5)
        lambda { 5.should arbitrary_matcher(:expected => 4) }.should fail_with("expected 4, got 5")
        lambda { 5.should arbitrary_matcher(:expected => 5).with(4) }.should fail_with("expected 4, got 5")
        5.should_not arbitrary_matcher(:expected => 4)
        5.should_not arbitrary_matcher(:expected => 5).with(4)
        lambda { 5.should_not arbitrary_matcher(:expected => 5) }.should fail_with("expected not 5, got 5")
        lambda { 5.should_not arbitrary_matcher(:expected => 4).with(5) }.should fail_with("expected not 5, got 5")
      end

      it "should handle the submitted block" do
        5.should arbitrary_matcher { 5 }
        5.should arbitrary_matcher(:expected => 4) { 5 }
        5.should arbitrary_matcher(:expected => 4).with(5) { 3 }
      end
  
      it "should explain when matcher does not support should_not" do
        lambda {
          5.should_not positive_only_matcher(:expected => 5)
        }.should fail_with(/Matcher does not support should_not.\n/)
      end

    end
  end
end
