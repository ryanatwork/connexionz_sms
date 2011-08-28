require 'simplecov'
SimpleCov.start

require File.join(File.dirname(__FILE__), '..', 'connexionz_sms.rb')

require 'rspec'
require 'rack/test'
require 'webmock/rspec'
set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end
