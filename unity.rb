require_relative 'lib/init'
require 'sinatra'

set :bind, '0.0.0.0'
set :app, Unity.new(SCHEMA, host: ENV['host'] || 'localhost', port: ENV['port'] || 6379)

def rescuing
  #begin
    content_type :json
    status 200

    res = yield if block_given?
  #rescue StandardError => e
  #  status 500
  #  e.message.to_json
  #end

  res.to_json
end

get '/' do
  ENV.to_h.to_json
end

delete '/flush' do
  settings.app.flush
end

get '/alive' do
  content_type :json
  status 200

  true.to_json
end

get '/ready' do
  rescuing do
    settings.app.ready?
  end
end

post '/payload' do
  rescuing do
    begin
      req = JSON.parse(request.body.read)

      status 200
      UnityLogger.info("Payload: #{req}")
      res = settings.app.process(req)
      UnityLogger.info("Response: #{res}")
      res
    rescue JSON::ParserError => e
      status 400
      UnityLogger.error(e.message)
      nil
    end
  end
end
