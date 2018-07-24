SCHEMA = {
  "type" => "object",
  "required" => ["ts", "sender", "message"],
  "properties" => {
    "ts" => {
      "type" => "string",
      "format" => "unix-timestamp",
    },
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
    },
    "sent-from-ip" => {
      "type" => "string",
      "format" => "ipv4"
    },
    "priority" => {
      "type" => "integer",
        "maximum" => 5,
        "minimum" => 1
    },
  },
  "additionalProperties" => false
}

def init_unix_format
  unix_timestamp = ->(value) {
    raise JSON::Schema::CustomFormatError.new("must be a valid base 10 integer") unless value.int?
  }

  JSON::Validator.register_format_validator("unix-timestamp", unix_timestamp, ["draft4"])
end

def payload_valid?(schema, payload)
  JSON::Validator.validate(schema, payload, :version => :draft4 )
end
