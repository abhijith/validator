require 'test/unit'
require 'json-schema'
require_relative '../lib/init.rb'

class SchemaTest < Test::Unit::TestCase

  def test_sender
    s = {
      "type" => "object",
      "required" => ["sender"],
      "properties" => {
        "sender" => {"type" => "string"}
      }
    }

    assert_equal true, payload_valid?(s, { "sender" => "a" })
    assert_equal false, payload_valid?(s, { "sender" => 1 })
  end

  def test_message
    s = {
      "type" => "object",
      "required" => ["message"],
      "properties" => {
        "sender" => {"type" => "string"},
        "message" => {
          "anyOf"=> [
            {"required"=> ["foo"]},
            {"required"=> ["baz"]}
          ],
          "properties" => {
            "foo" => {"type" => "string", "optional" => true},
            "baz" => {"type" => "string", "optional" => true},
          },
          "type" => "object",
          "additionalProperties" => false
        }
      },
    }

    assert_equal true, payload_valid?(s, { "message" => { "foo" => "bar", "baz" => "bang" }})
    assert_equal true, payload_valid?(s, { "message" => { "foo" => "bar"}})
    assert_equal true, payload_valid?(s, { "message" => { "baz" => "bang" }})
    assert_equal false, payload_valid?(s, { "message" => { "foo" => "bar", "baz" => "bang", "wrong" => 1 }})
  end

  def test_sent_from_ip
    s = {
      "type" => "object",
      "properties" => {
        "sent-from-ip" => {
          "type" => "string",
          "format" => "ipv4"
        }
      }
    }

    assert_equal true, payload_valid?(s, {"sent-from-ip" => "10.0.0.1"})
    assert_equal true, payload_valid?(s, {})
    assert_equal false, payload_valid?(s, {"sent-from-ip" => "255.255.255.256"})
    assert_equal false, payload_valid?(s, {"sent-from-ip" => "::1"})
    assert_equal false, payload_valid?(s, {"sent-from-ip" => "1"})
    assert_equal false, payload_valid?(s, {"sent-from-ip" => 1})
    assert_equal false, payload_valid?(s, {"sent-from-ip" => :a})
  end

  def test_priority
    s = {
      "type" => "object",
      "properties" => {
        "priority" => {
          "type" => "integer",
        }
      }
    }

    assert_equal true, payload_valid?(s, {"priority" => 1})
    assert_equal true, payload_valid?(s, {})
    assert_equal true, payload_valid?(s, {"priority" => -1})
    assert_equal true, payload_valid?(s, {"priority" => -1})
    assert_equal false, payload_valid?(s, { "priority" => "" })
  end

  def test_ts
    s = {
      "properties" => {
        "ts" => {
          "type" => "string",
          "format" => "unix-timestamp",
        }
      }
    }

    assert_equal true, payload_valid?(s, { "ts" => "1530228282" })
    assert_equal true, payload_valid?(s, { "ts" => "-1530228282" })
    assert_equal false, payload_valid?(s, { "ts" => "3147483649x" })
    assert_equal false, payload_valid?(s, { "ts" => "x3147483648" })
  end

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
