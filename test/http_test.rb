ENV['RACK_ENV'] = 'test'

require_relative 'init'
require 'rack/test'

class HttpTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    delete '/flush'
  end

  def teardown
    delete '/flush'
  end

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

  def assert_payload(expect, payload)
    post '/payload', payload.to_json
    assert last_response.send(:ok?)
    assert_equal expect.to_s, last_response.body
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

    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(true, { "ts" => "-1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(false, { "ts" => "x1530228282x", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(false, { "ts" => "asdf", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})

    # sender
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(false, { "ts" => "1530228282", "sender" => 1, "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(false, { "ts" => "1530228282", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})

    # message
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(false, { "ts" => "1530228282", "sender" => "a", "sent-from-ip" => "10.0.0.1"})

    # extra attribute(s) in message
    assert_payload(false, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang", "foobar" => "invalid" }, "sent-from-ip" => "10.0.0.1"})

    # sent-from-ip
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }})
    assert_payload(false, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "256.256.256.256"})

    # priority
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1 })
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_payload(false, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => "a" })

    # extra attributes at top level
    assert_payload(false, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1, "sneaked-in" => true })

    # ideal payload
    assert_payload(true, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1 })
  end

end
