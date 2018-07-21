require 'test/unit'
require 'json-schema'
require_relative '../lib/init.rb'

class UnityTest < Test::Unit::TestCase

  def test_payload_structure
    s = SCHEMA

    # timestamp
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal true, payload_valid?(s, { "ts" => "-1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal false, payload_valid?(s, { "ts" => "x1530228282x", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal false, payload_valid?(s, { "ts" => "asdf", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})

    # sender
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "sender" => 1, "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})

    # message
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "sent-from-ip" => "10.0.0.1"})

    # extra attribute(s) in message
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang", "foobar" => "invalid" }, "sent-from-ip" => "10.0.0.1"})

    # sent-from-ip
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }})
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "256.256.256.256"})

    # priority
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1 })
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1"})
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => "a" })

    # extra attributes at top level
    assert_equal false, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1, "sneaked-in" => true })

    # ideal payload
    assert_equal true, payload_valid?(s, { "ts" => "1530228282", "sender" => "a", "message" => { "foo" => "bar", "baz" => "bang" }, "sent-from-ip" => "10.0.0.1", "priority" => 1 })
  end

end
