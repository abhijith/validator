require_relative 'init'

def main(payload)
  if payload_valid?(SCHEMA, payload)
    # push into queue
    true
  else
    # reject message
    false
  end
end
