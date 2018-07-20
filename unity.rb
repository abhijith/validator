require_relative 'lib/init'
require 'sinatra'

def rescuing
  begin
    content_type :json
    status 200

    res = yield if block_given?
  rescue StandardError => e
    status 500
    p e
    e.message.to_json
  end

  res.to_json
end

get '/' do
end

get '/alive' do
  content_type :json
  status 200

  true.to_json
end

get '/ready' do
  rescuing do
    # considered ready if we can make connection to queue
    true
  end
end

post '/payload' do
  rescuing do
    # is syntactically valid json
    # is valid payload
    begin
      req = JSON.parse(request.body.read)

      status 200
      UnityLogger.info("Payload: #{req}")
      res = main(req)
      UnityLogger.info("Response: #{res}")
      res
    rescue JSON::ParserError => e
      status 400
      UnityLogger.error(e.message)
      nil
    rescue InvalidPayload => e
      status 400
      UnityLogger.error(e.message)
      nil
    end
  end
end
