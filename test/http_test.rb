ENV['RACK_ENV'] = 'test'

require_relative 'init'
require 'rack/test'

class HttpTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get '/'
    assert last_response.ok?
    assert_equal "", last_response.body
  end

  def test_alive
    get '/alive'
    assert last_response.ok?
    assert_equal "true", last_response.body
  end

  def test_ready
    get '/ready'
    assert last_response.ok?
    assert_equal "true", last_response.body
  end

  def test_main
    payload = { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1 }

    post '/payload', payload.to_json
    assert last_response.send(:ok?)

    post '/payload/', payload.to_json
    assert last_response.send(:client_error?)

    payload = '{"ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1'
    post '/payload/', payload
    assert last_response.send(:client_error?)
  end

end
