# connexionz_sms.rb
 require 'sinatra'
 require 'connexionz'
 require 'haml'
 require 'smsified'
 require 'json'

 set :sms_user, ENV['SMS_USER'] || 'foo'
 set :password, ENV['PASSWORD'] || 'secret'
 set :sender_phone, ENV['SMS_PHONE'] || '555-555-1212'

 get '/' do
   haml :root
 end

 get '/route_et/:name' do
   #matches "GET /route_et/19812"
   @client = Connexionz::Client.new({:endpoint => "http://12.233.207.166"})
   @platform_info = @client.route_position_et({:platformno => "#{params[:name]}"})

   if @platform_info.route_position_et.platform.nil?
     sms_message = "No bus stop found"
   else
     name = @platform_info.route_position_et.platform.name
     arrival_scope = @platform_info.route_position_et.content.max_arrival_scope
     sms_message = ""

     if @platform_info.route_position_et.platform.route.nil?
       sms_message = "No arrivals for next #{arrival_scope} minutes"
     elsif @platform_info.route_position_et.platform.route.class == Array
       @platforms = @platform_info.route_position_et.platform.route

       @platforms.each do |platform|
         sms_message += "Route #{platform.route_no}-Destination #{platform.destination.name}-ETA #{platform.destination.trip.eta } minutes "
       end
     else
       route_no = @platform_info.route_position_et.platform.route.route_no
       destination = @platform_info.route_position_et.platform.route.destination.name
       eta = @platform_info.route_position_et.platform.route.destination.trip.eta
       sms_message = "Route #{route_no} " + "-Destination #{destination} " + "-ETA #{eta} minutes"
     end
   end

   sms_message.rstrip
 end

 post '/incoming' do

   puts "Hello"

   response = JSON.parse(request.env["rack.input"].read)

   message =  response["inboundSMSMessageNotification"]["inboundSMSMessage"]["message"]
   callerID =  response["inboundSMSMessageNotification"]["inboundSMSMessage"]["senderAddress"]
   time =  response["inboundSMSMessageNotification"]["inboundSMSMessage"]["dateTime"]
   destination = response["inboundSMSMessageNotification"]["inboundSMSMessage"]["destinationAddress"]

   text = "From: #{callerID} \nMessage: #{message}\nDate & Time: #{time}\n\n"

   if destination == "15717621172"
     @client = Connexionz::Client.new({:endpoint => "http://realtime.commuterpage.com"})
   else #default to Santa Clarita
     @client = Connexionz::Client.new({:endpoint => "http://12.233.207.166"})
   end

   @platform_info = @client.route_position_et({:platformno => "#{message}"})
   if @platform_info.route_position_et.platform.nil?
      sms_message = "No bus stop found"
    else
      name = @platform_info.route_position_et.platform.name
      arrival_scope = @platform_info.route_position_et.content.max_arrival_scope
      sms_message = ""

      if @platform_info.route_position_et.platform.route.nil?
        sms_message = "No arrivals for next #{arrival_scope} minutes"
      elsif @platform_info.route_position_et.platform.route.class == Array
        @platforms = @platform_info.route_position_et.platform.route

        @platforms.each do |platform|
          sms_message += "Route #{platform.route_no}-Destination #{platform.destination.name}-ETA #{platform.destination.trip.eta } minutes "
        end
      else
        route_no = @platform_info.route_position_et.platform.route.route_no
        destination = @platform_info.route_position_et.platform.route.destination.name
        eta = @platform_info.route_position_et.platform.route.destination.trip.eta
        sms_message = "Route #{route_no} " + "-Destination #{destination} " + "-ETA #{eta} minutes"
      end
   end

   oneapi = Smsified::OneAPI.new(:username => settings.sms_user, :password => settings.password)
   oneapi.send_sms :address => callerID, :message => sms_message, :sender_address => settings.sender_phone

   puts sms_message

end
