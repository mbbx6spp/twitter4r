class TweetsController < ApplicationController
  # GET /tweets
  # GET /tweets.json
  # GET /tweets.xml
  def index
    respond_to do |format|
      begin
        @tweets = TweetApp::ClientContext.timeline_for(:me)
        format.html # index.rhtml
        format.json { render :json => @tweets.to_json }
        format.xml  { render :xml => @tweets.to_xml }
      rescue Twitter::RESTError => re
        handle_rest_error(re, format)
      end
    end
  end

  # GET /tweets/1
  # GET /tweets/1.json
  # GET /tweets/1.xml
  def show
    respond_to do |format|
      begin
        @tweet = TweetApp::ClientContext.status(:get, params[:id])
        format.html # show.rhtml
        format.json { render :json => @tweet.to_json }
        format.xml  { render :xml => @tweet.to_xml }
      rescue Twitter::RESTError => re
        handle_rest_error(re, format)
      end
    end
  end

  # GET /tweets/new
  def new
  end

  # POST /tweets
  # POST /tweets.json
  # POST /tweets.xml
  def create
    respond_to do |format|
      begin
        @tweet = TweetApp::ClientContext.status(:post, params[:text])
        flash[:notice] = 'Tweet was successfully created.'
        format.html { redirect_to tweet_url(@tweet) }
        format.json { head :created, :location => tweet_url(@tweet) }
        format.xml  { head :created, :location => tweet_url(@tweet) }
      rescue Twitter::RESTError => re
        handle_rest_error(re, format, 'new')
      end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  # DELETE /tweets/1.xml
  def destroy
    respond_to do |format|
      begin
        @tweet = TweetApp::ClientContext.status(:delete, params[:id])
        flash[:message] = "Tweet with id #{params[:id]} was deleted from Twitter"
        format.html { redirect_to tweets_url }
        format.json { head :ok }
        format.xml  { head :ok }
      rescue Twitter::RESTError => re
        handle_rest_error(re, format)
      end
    end
  end
  
  protected
    def handle_rest_error(error, format, template = 'common/twitter_error')
      @error = error
      format.html { render :template => template }
      format.json { head 503, :json => error.to_json }
      format.xml  { head 503, :xml => error.to_json }
    end
end

