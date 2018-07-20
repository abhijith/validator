#### Example valid payload

```
	{
		"ts": "1530228282",
		"sender": "testy-test-service",
		"message": {
			"foo": "bar",
			"baz": "bang"
		},
		"sent-from-ip": "1.2.3.4",
		"priority": 2
	}

```

#### Validation rules:

* ts
  - mandatory
  - Unix timestamp

* sender
  - mandatory
  - must be a string

* message
  - mandatory
  - must be a JSON object and have at least one field set

* sent-from-ip
  - optional
  - if present, must be a valid IPv4 address


All fields not listed in the example above are invalid, and should
result in the message being rejected.
