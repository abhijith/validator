class String
  def int?
    self.to_i.to_s == self
  end
end

unix_timestamp = ->(value) {
  raise JSON::Schema::CustomFormatError.new("must be a valid base 10 integer") unless value.int?
}

JSON::Validator.register_format_validator("unix-timestamp", unix_timestamp, ["draft4"])
