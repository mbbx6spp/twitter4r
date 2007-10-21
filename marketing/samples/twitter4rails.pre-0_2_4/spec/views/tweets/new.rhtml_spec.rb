require File.dirname(__FILE__) + '/../../spec_helper'

describe "/tweets/new.rhtml" do
  include TweetsHelper
  
  it "should render new form" do
    render "/tweets/new.rhtml"
    
    response.should have_tag("form[action=?][method=post]", tweets_path) do
    end
  end
end


