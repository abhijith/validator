require 'sinatra'
require_relative 'lib/unity'
require_relative 'lib/initializer'
require_relative 'test/data'

def rescuing
  begin
    content_type :json
    status 200

    res = yield if block_given?
  rescue StandardError => e
    status 500
    e.message.to_json
  end

  res.to_json
end

get '/' do
  rescuing do
    UnityLogger.info("Flushing data")
    flush
    UnityLogger.info("Initializing data")
    init_data
    UnityLogger.info("Initialized data")
    true
  end
end

post '/ads/match' do
  rescuing do
    req = JSON.parse(request.body.read, symbolize_names: true)
    begin
      status 200
      UnityLogger.info("Got request to match: #{req}")
      res = main(req)
      UnityLogger.info("Response: #{res.to_h}")
      res.to_h
    rescue CountryNotFound, ChannelNotFound => e
      status 400
      UnityLogger.error(e.message)
      nil
    end
  end
end
