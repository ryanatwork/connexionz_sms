require File.dirname(__FILE__) + '/spec_helper'

describe 'The HelloWorld App' do
  it "says hello" do
    get '/'
    last_response.should be_ok
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