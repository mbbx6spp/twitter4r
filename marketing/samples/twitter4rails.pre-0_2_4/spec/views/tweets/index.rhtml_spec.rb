require File.dirname(__FILE__) + '/../../spec_helper'

describe "/tweets/index.rhtml" do
  include TweetsHelper
  
  before do
    tweet_98 = mock_model(Twitter::Status)
    tweet_99 = mock_model(Twitter::Status)
    user = mock_model(Twitter::User)
    user.stub!(:screen_name).and_return("screen_name")
    tweet_98.stub!(:user).and_return(user)
    tweet_98.stub!(:id).and_return("2342345")
    tweet_98.stub!(:text).and_return("Tweet text content")
    tweet_98.stub!(:created_at).and_return(Time.now)

    tweet_99.stub!(:user).and_return(user)
    tweet_99.stub!(:id).and_return("2342345")
    tweet_99.stub!(:text).and_return("Tweet text content")
    tweet_99.stub!(:created_at).and_return(Time.now)

    assigns[:tweets] = [tweet_98, tweet_99]
  end

  it "should render list of tweets" do
    render "/tweets/index.rhtml"
  end
end

