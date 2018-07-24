#### Project Structure

```
	$ tree unity/

	unity/
	├── docker-compose.yml
	├── Dockerfile.app
	├── Dockerfile.queue
	├── Gemfile
	├── Gemfile.lock
	├── k8s.yaml
	├── lib
	│   ├── init.rb
	│   ├── logger.rb
	│   ├── schema.rb
	│   ├── unity.rb
	│   └── utils.rb
	├── README.md
	├── test
	│   ├── all.rb
	│   ├── http_test.rb
	│   ├── init.rb
	│   ├── schema_test.rb
	│   └── unity_test.rb
	├── TODO
	└── unity.rb

2 directories, 19 files

```
#### Install instructions


#### Running the Code

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
  - both fields are strings

* sent-from-ip
  - optional
  - if present, must be a valid IPv4 address

* priority
  - optional
  - if present, must be a integer
  - minimum 1 and maximum 5


All fields not listed in the example above are invalid, and should
result in the message being rejected.


#### Components

* WebServer

* Schema validator

* Queue abstraction / interface

* Dockerfiles

* Docker Compose Manifest

* Kubernetes Manifest

#### URLs exposed via the webserver

|url     | type   | params | desc     |
|:-------|:------:|:------:|:--------:|
| /      | GET    | None   | Index
| /flush | DELETE | None   | Clears the queue
| /alive | GET    | None   | Check if WebServer end-point is accessible
| /ready | GET    | None   | Check if Queue is accessible
| /send  | POST   | None   | Accepts JSON payload and pushes into a queue if schema passes validation


#### Sample data for testing



#### Extending and other ideas
