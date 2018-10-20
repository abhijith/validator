require_relative 'lib/init'
require 'sinatra'

set :bind, '0.0.0.0'
set :app, App.new(SCHEMA, host: ENV['QUEUE_HOST'] || 'localhost', port: ENV['QUEUE_PORT'] || 6379)

def rescuing
  begin
    content_type :json
    status 200

    res = yield if block_given?
  rescue StandardError => e
    status 500
    AppLogger.error(e.backtrace.join("\n"))
    e.message.to_json
  end

  res.to_json
end

get '/' do
end

delete '/flush' do
  content_type :json
  status 200

  settings.app.flush
  true.to_json
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

post '/send' do
  rescuing do
    begin
      req = JSON.parse(request.body.read)

      status 200
      AppLogger.info("Payload: #{req}")
      res = settings.app.process(req)
      AppLogger.info("Response: #{res}")
      res
    rescue JSON::ParserError => e
      status 400
      AppLogger.error(e.message)
      nil
    end
  end
end
