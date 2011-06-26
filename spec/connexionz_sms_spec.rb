require File.join(File.dirname(__FILE__), '/', 'connexionz_sms.rb')


require 'sinatra'
require 'rack/test'
require 'rspec'


set :environment, :test

describe 'The HelloWorld App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello world!'
  end
  
  it "returns a parameter" do
    get '/hello/ryan'
    last_response.should be_ok
    last_response.body.should == 'Hello ryan!'
  end
  
  it "should return no bus stop found" do
    get '/route_et/10000'
    last_response.should be_ok
    last_response.body.should == 'No bus stop found'
  end
end