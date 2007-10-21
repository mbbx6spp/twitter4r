require File.dirname(__FILE__) + '/../../spec_helper'

describe "/tweets/show.rhtml" do
  include TweetsHelper
  
  before do
    @tweet = mock_model(Twitter::Status)
    @user = mock_model(Twitter::User)
    @user.stub!(:screen_name).and_return("screen_name")
    @tweet.stub!(:user).and_return(@user)
    @tweet.stub!(:id).and_return("2342345")
    @tweet.stub!(:text).and_return("Tweet text content")
    @tweet.stub!(:created_at).and_return(Time.now)
    assigns[:tweet] = @tweet
  end

  it "should render attributes in <p>" do
    render "/tweets/show.rhtml"
  end
end

