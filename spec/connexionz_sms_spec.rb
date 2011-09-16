require File.dirname(__FILE__) + '/spec_helper'

describe 'Connexionz SMS Application' do

  describe "the home page" do
    it "Should return the home page" do
      get '/'
      last_response.should be_ok
    end
  end

  describe "route_et" do
    it "should return no bus stop found" do
      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?contenttype=SQLXML&Name=RoutePositionET.xml&platformno=10000").
        to_return(:status => 200, :body => fixture("no_platform.xml"))
      get '/route_et/10000'
      last_response.should be_ok
      last_response.body.should == 'No bus stop found'
    end

    it "should return no arrivals for scope" do
      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?contenttype=SQLXML&Name=RoutePositionET.xml&platformno=15414").
        to_return(:status => 200, :body => fixture("no_arrivals.xml"))
      get '/route_et/15414'
      last_response.should be_ok
      last_response.body.should == "No arrivals for next 30 minutes"
    end

    it "should return the time for the one arrival" do
      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?contenttype=SQLXML&Name=RoutePositionET.xml&platformno=10656").
        to_return(:status => 200, :body => fixture("one_arrival.xml"))
      get '/route_et/10656'
      last_response.should be_ok
      last_response.body.should =="Route 2 -Destination Val Verde -ETA 20 minutes"
    end


    it "should return the time for the next arrival" do
      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?contenttype=SQLXML&Name=RoutePositionET.xml&platformno=10246").
        to_return(:status => 200, :body => fixture("route_et.xml"))
      get '/route_et/10246'
      last_response.body.should == "Route 1-Destination Castaic-ETA 24 minutes Route 4-Destination LARC-ETA 19 minutes Route 6-Destination Shadow Pines-ETA 17 minutes Route 14-Destination Plum Cyn-ETA 11 minutes"
    end
  end

  describe "incoming" do
    it "should return no bus stop found message" do
      json = '{
                "inboundSMSMessageNotification": {
                  "inboundSMSMessage": {
                    "dateTime": "2011-05-11T18:05:54.546Z",
                    "destinationAddress": "16575550100",
                    "message": "10000",
                    "messageId": "ef795d3dac56a62fef3ff1852b0c123a",
                    "senderAddress": "14075550100"
                  }
                }
              }'
      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?Name=RoutePositionET.xml&contenttype=SQLXML&platformno=10000").
        to_return(:status => 200, :body => fixture("no_platform.xml"))

      stub_request(:post, "https://foo:secret@api.smsified.com/v1/smsmessaging/outbound/555-555-1212/requests").
         with(:body => {"address"=>"14075550100", "message"=>"No bus stop found"}).
         to_return(:status => 200, :body => "", :headers => {})

      post :incoming, json
      last_response.should be_ok
    end

    it "should return no arrivals for next 30 minutes" do
      json = '{
                "inboundSMSMessageNotification": {
                  "inboundSMSMessage": {
                    "dateTime": "2011-05-11T18:05:54.546Z",
                    "destinationAddress": "16575550100",
                    "message": "15414",
                    "messageId": "ef795d3dac56a62fef3ff1852b0c123a",
                    "senderAddress": "14075550100"
                  }
                }
              }'
      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?Name=RoutePositionET.xml&contenttype=SQLXML&platformno=15414").
        to_return(:status => 200, :body => fixture("no_arrivals.xml"))

      stub_request(:post, "https://foo:secret@api.smsified.com/v1/smsmessaging/outbound/555-555-1212/requests").
         with(:body => {"address"=>"14075550100", "message"=>"No arrivals for next 30 minutes"}).
         to_return(:status => 200, :body => "", :headers => {})

      post :incoming, json
      last_response.should be_ok
    end

    it "should return no arrivals for next 30 minutes" do
      json = '{
                "inboundSMSMessageNotification": {
                  "inboundSMSMessage": {
                    "dateTime": "2011-05-11T18:05:54.546Z",
                    "destinationAddress": "16575550100",
                    "message": "10246",
                    "messageId": "ef795d3dac56a62fef3ff1852b0c123a",
                    "senderAddress": "14075550100"
                  }
                }
              }'

      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?Name=RoutePositionET.xml&contenttype=SQLXML&platformno=10246").
        to_return(:status => 200, :body => fixture("route_et.xml"))

      stub_request(:post, "https://foo:secret@api.smsified.com/v1/smsmessaging/outbound/555-555-1212/requests").
         with(:body => {"address"=>"14075550100", "message"=>"Route 1-Destination Castaic-ETA 24 minutes Route 4-Destination LARC-ETA 19 minutes Route 6-Destination Shadow Pines-ETA 17 minutes Route 14-Destination Plum Cyn-ETA 11 minutes "},
              :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "", :headers => {})

      post :incoming, json
      last_response.should be_ok
    end

    it "should return no arrivals for next 30 minutes" do
      json = '{
                "inboundSMSMessageNotification": {
                  "inboundSMSMessage": {
                    "dateTime": "2011-05-11T18:05:54.546Z",
                    "destinationAddress": "16575550100",
                    "message": "10656",
                    "messageId": "ef795d3dac56a62fef3ff1852b0c123a",
                    "senderAddress": "14075550100"
                  }
                }
              }'

      stub_request(:get, "http://businfo.santa-clarita.com/rtt/public/utility/file.aspx?Name=RoutePositionET.xml&contenttype=SQLXML&platformno=10656").
        to_return(:status => 200, :body => fixture("one_arrival.xml"))

      stub_request(:post, "https://foo:secret@api.smsified.com/v1/smsmessaging/outbound/555-555-1212/requests").
         with(:body => {"address"=>"14075550100", "message"=>"Route 2 -Destination Val Verde -ETA 20 minutes"},
              :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "", :headers => {})

      post :incoming, json
      last_response.should be_ok
    end
  end

  describe "it should return arrival times for Arlington, VA" do
    it "should return a single arrival time" do
      json = '{
                "inboundSMSMessageNotification": {
                  "inboundSMSMessage": {
                    "dateTime": "2011-05-11T18:05:54.546Z",
                    "destinationAddress": "15717621172",
                    "message": "87017",
                    "messageId": "ef795d3dac56a62fef3ff1852b0c123a",
                    "senderAddress": "14075550100"
                  }
                }
              }'

      stub_request(:get, "http://realtime.commuterpage.com/rtt/public/utility/file.aspx?Name=RoutePositionET.xml&contenttype=SQLXML&platformno=87017").
          to_return(:status => 200, :body => fixture("va_single.xml"))

      stub_request(:post, "https://foo:secret@api.smsified.com/v1/smsmessaging/outbound/555-555-1212/requests").
         with(:body => {"address"=>"14075550100", "message"=>"Route 87 -Destination Shirlington Station -ETA 17 minutes"},
              :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "", :headers => {})

      post :incoming, json
      last_response.should be_ok
    end
  end
end
