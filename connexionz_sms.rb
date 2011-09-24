# connexionz_sms.rb
 require 'sinatra'
 require 'connexionz'
 require 'haml'
 require 'smsified'
 require 'tropo-webapi-ruby'
 require 'json'

 set :sms_user, ENV['SMS_USER']
 set :password, ENV['PASSWORD']
 set :sender_phone, ENV['SMS_PHONE']
 set :va_phone, ENV['VA_PHONE']
 set :char_phone, ENV['CHAR_PHONE']

 get '/' do
   haml :root
 end

 get '/sc/:name' do
   #matches "GET /sc/19812"
   get_et_info('sc',params[:name])
 end

 get '/va/:name' do
   #matches "GET /va/41215"
   get_et_info('va',params[:name])
 end

get '/char/:name' do
   #matches "GET /char/19812"
   get_et_info('char',params[:name])
 end


 post '/incoming' do

   response = JSON.parse(request.env["rack.input"].read)

   message =  response["inboundSMSMessageNotification"]["inboundSMSMessage"]["message"]
   callerID =  response["inboundSMSMessageNotification"]["inboundSMSMessage"]["senderAddress"]
   time =  response["inboundSMSMessageNotification"]["inboundSMSMessage"]["dateTime"]
   sent_to = response["inboundSMSMessageNotification"]["inboundSMSMessage"]["destinationAddress"]

   text = "To: #{sent_to}\nFrom: #{callerID} \nMessage: #{message}\nDate & Time: #{time}\n\n"
   puts text

   if sent_to == settings.va_phone
     location = "va"
   elsif sent_to == settings.char_phone
     location = "char"
   else #default to Santa Clarita
     location = "sc"
   end

   sms_message = get_et_info(location,message)

   oneapi = Smsified::OneAPI.new(:username => settings.sms_user, :password => settings.password)
   oneapi.send_sms :address => callerID, :message => sms_message, :sender_address => sent_to

   puts sms_message

end

post '/index.json' do

  t = Tropo::Generator.new

  t.ask :name => 'digit',
        :timeout => 60,
        :say => {:value => "Enter the five digit bus stop number"},
        :choices => {:value => "[5 DIGITS]", :mode => "keypad"}

  t.on :event => 'continue', :next => '/continue.json'

  t.response

end

post '/continue.json' do

  v = Tropo::Generator.parse request.env["rack.input"].read

  t = Tropo::Generator.new

  answer = v[:result][:actions][:digit][:value]

  stop = get_et_info('sc', answer)

  t.say(:value => stop)

  t.response

end

def get_et_info(location,platform)

  if location == "va"
    @client = Connexionz::Client.new({:endpoint => "http://realtime.commuterpage.com"})
  elsif location == "char"
   @client = Connexionz::Client.new({:endpoint => "http://avlweb.charlottesville.org"})
  else
    @client = Connexionz::Client.new({:endpoint => "http://12.233.207.166"})
  end

   @platform_info = @client.route_position_et({:platformno => platform})

   if @platform_info.route_position_et.platform.nil?
     sms_message = "No bus stop found"
   else
      name = @platform_info.route_position_et.platform.name
      arrival_scope = @platform_info.route_position_et.content.max_arrival_scope
      sms_message = ""
      eta = ""
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
        if @platform_info.route_position_et.platform.route.destination.trip.is_a?(Array)
         @platform_info.route_position_et.platform.route.destination.trip.each do |mult_eta|
           eta += "#{mult_eta.eta} min "
         end
       else
         eta = "#{@platform_info.route_position_et.platform.route.destination.trip.eta} min"
       end
       sms_message = "Route #{route_no} " + "-Destination #{destination} " + "-ETA #{eta}"
      end
   end
  sms_message
 end
