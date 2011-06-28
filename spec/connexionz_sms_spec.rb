require File.dirname(__FILE__) + '/spec_helper'

describe 'Connexionz SMS Application' do
  
  describe "the home page" do
    it "Should return the home page" do
      get '/'
      last_response.should be_ok
    end
  end

  describe "passing a parameter" do
    it "returns a parameter" do
      get '/hello/ryan'
      last_response.should be_ok
      last_response.body.should == 'Hello ryan!'
    end
  end
  
  describe "route_et" do
    it "should return no bus stop found" do
      get '/route_et/10000'
      last_response.should be_ok
      last_response.body.should == 'No bus stop found'
    end
    
    it "should return no arrivals for scope" do
      get '/route_et/15414'
      last_response.should be_ok
      last_response.body.should == "No arrivals for next 30 minutes"
    end
  end
  
  
end