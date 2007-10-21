require File.dirname(__FILE__) + '/../spec_helper'

describe TweetsController, "#route_for" do

  it "should map { :controller => 'tweets', :action => 'index' } to /my/tweets" do
    route_for(:controller => "tweets", :action => "index").should == "/my/tweets"
  end
  
  it "should map { :controller => 'tweets', :action => 'new' } to /my/tweets/new" do
    route_for(:controller => "tweets", :action => "new").should == "/my/tweets/new"
  end
  
  it "should map { :controller => 'tweets', :action => 'show', :id => 1 } to /my/tweets/1" do
    route_for(:controller => "tweets", :action => "show", :id => 1).should == "/my/tweets/1"
  end
  
  it "should map { :controller => 'tweets', :action => 'destroy', :id => 1} to /my/tweets/1" do
    route_for(:controller => "tweets", :action => "destroy", :id => 1).should == "/my/tweets/1"
  end
  
end

describe TweetsController, "handling GET /tweets" do

  before do
    @tweet = mock(Twitter::Status)
    @expected_tweets = [@tweet]
    TweetApp::ClientContext.stub!(:timeline_for).and_return(@expected_tweets)
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all tweets" do
    TweetApp::ClientContext.should_receive(:timeline_for).with(:me).and_return(@expected_tweets)
    do_get
  end
  
  it "should assign the found tweets for the view" do
    TweetApp::ClientContext.should_receive(:timeline_for).with(:me).and_return(@expected_tweets)
    do_get
    assigns[:tweets].should be(@expected_tweets)
  end
end

describe TweetsController, "handling GET /tweets.xml" do

  before do
    @xml = "XML"
    @tweet = mock_model(Twitter::Status, :to_xml => @xml)
    @expected_tweets = [@tweet]
    TweetApp::ClientContext.stub!(:timeline_for).and_return(@expected_tweets)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all tweets" do
    TweetApp::ClientContext.should_receive(:timeline_for).with(:me).and_return(@expected_tweets)
    do_get
  end
  
  it "should render the found tweets as xml" do
    @expected_tweets.should_receive(:to_xml).and_return(@xml)
    do_get
    response.body.should be(@xml)
  end
end

describe TweetsController, "handling GET /tweets.json" do

  before do
    @json = "JSON"
    @mime_type = 'text/x-json'
    @tweet = mock_model(Twitter::Status, :to_json => @json)
    @expected_tweets = [@tweet]
    TweetApp::ClientContext.stub!(:timeline_for).and_return(@expected_tweets)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = @mime_type
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all tweets" do
    TweetApp::ClientContext.should_receive(:timeline_for).with(:me).and_return(@expected_tweets)
    do_get
  end
  
  it "should render the found tweets as xml" do
    @expected_tweets.should_receive(:to_json).and_return(@json)
    do_get
    response.body.should be(@json)
  end
end

describe TweetsController, "handling GET /tweets/1" do

  before do
    @id = "1"
    @tweet = mock_model(Twitter::Status)
    TweetApp::ClientContext.stub!(:status).and_return(@tweet)
  end
  
  def do_get
    get :show, :id => @id
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show template" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the tweet requested" do
    TweetApp::ClientContext.should_receive(:status).with(:get, @id).and_return(@tweet)
    do_get
  end
  
  it "should assign the found tweet for the view" do
    do_get
    assigns[:tweet].should equal(@tweet)
  end
end

describe TweetsController, "handling GET /tweets/1.xml" do

  before do
    @id = "1"
    @xml = "XML"
    @mime_type = 'application/xml'
    @tweet = mock_model(Twitter::Status, :to_xml => @xml)
    TweetApp::ClientContext.stub!(:status).and_return(@tweet)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = @mime_type
    get :show, :id => @id
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the tweet requested" do
    TweetApp::ClientContext.should_receive(:status).with(:get, @id).and_return(@tweet)
    do_get
  end
  
  it "should render the found tweet as xml" do
    @tweet.should_receive(:to_xml).and_return(@xml)
    do_get
    response.body.should be(@xml)
  end
end

describe TweetsController, "handling GET /tweets/1.json" do

  before do
    @id = "1"
    @json = "JSON"
    @mime_type = 'text/x-json'
    @tweet = mock_model(Twitter::Status, :to_json => @json)
    TweetApp::ClientContext.stub!(:status).and_return(@tweet)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = @mime_type
    get :show, :id => @id
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the tweet requested" do
    TweetApp::ClientContext.should_receive(:status).with(:get, @id).and_return(@tweet)
    do_get
  end
  
  it "should render the found tweet as xml" do
    @tweet.should_receive(:to_json).and_return(@json)
    do_get
    response.body.should be(@json)
  end
end

describe TweetsController, "handling GET /tweets/new" do

  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
end

describe TweetsController, "handling POST /tweets" do

  before do
    @id = "1"
    @tweet = mock_model(Twitter::Status, :to_param => @id)
    TweetApp::ClientContext.stub!(:status).and_return(@tweet)
    @msg = "My new tweet!"
    @params = {
      :text => @msg,
    }
  end
  
  def do_post
    post :create, @params
  end
  
  it "should create a new tweet" do
    TweetApp::ClientContext.should_receive(:status).with(:post, @msg).and_return(@tweet)
    do_post
  end

  it "should redirect to the new tweet" do
    do_post
    response.should redirect_to(tweet_url(@id))
  end
end

describe TweetsController, "handling DELETE /tweets/1" do

  before do
    @id = "1"
    @tweet = mock_model(Twitter::Status)
    TweetApp::ClientContext.stub!(:status).and_return(@tweet)
  end
  
  def do_delete
    delete :destroy, :id => @id
  end

  it "should find the tweet requested" do
    TweetApp::ClientContext.should_receive(:status).with(:delete, @id).and_return(@tweet)
    do_delete
  end
  
  it "should redirect to the tweets list" do
    do_delete
    response.should redirect_to(tweets_url)
  end
end

# Error cases
describe "handling erroneous HTTP request", :shared => true do

  before(:each) do
    @rest_error = Twitter::RESTError.new
    TweetApp::ClientContext.stub!(:timeline_for).and_raise(@rest_error)
    TweetApp::ClientContext.stub!(:status).and_raise(@rest_error)
    Twitter::RESTError.stub!(:new).and_return(@rest_error)
  end
  
  it "should render 'common/twitter_error' template" do
    do_action
    response.should render_template(template)
  end

  after(:each) do
    @error = nil
  end  
end

describe TweetsController, "handling erroneous GET /tweets" do
  def do_action
    get :index
  end

  def template; 'common/twitter_error'; end
  
  it_should_behave_like "handling erroneous HTTP request"
end

describe TweetsController, "handling erroneous POST /tweets" do
  def do_action
    post :create, :text => 'tweet text'
  end
  
  def template; 'new'; end
  
  it_should_behave_like "handling erroneous HTTP request"
end

describe TweetsController, "handling erroneous DELETE /tweets/:id" do
  def do_action
    delete :destroy, :id => "1"
  end
  
  def template; 'common/twitter_error'; end

  it_should_behave_like "handling erroneous HTTP request"
end

describe TweetsController, "handling erroneous GET /tweets/:id" do
  def do_action
    get :show, :id => "1"
  end
  
  def template; 'common/twitter_error'; end
  
  it_should_behave_like "handling erroneous HTTP request"
end

