#### JSON Schema validator sample application

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

#### Project Structure

```
	.
	├── .dockerignore
	├── .gitignore
	├── build.sh
	├── docker-compose.yaml
	├── Dockerfile.app
	├── Dockerfile.queue
	├── Gemfile
	├── Gemfile.lock
	├── k8s.yaml
	├── lib
	│   ├── init.rb
	│   ├── logger.rb
	│   ├── schema.rb
	│   ├── app.rb
	│   └── utils.rb
	├── README.md
	├── test
	│   ├── all.rb
	│   ├── http_test.rb
	│   ├── init.rb
	│   └── schema_test.rb
	└── app.rb

```

#### Environment Details

* Platform: Linux

* Docker
  - client:	18.03.0-ce
  - server:	18.03.0-ce

* minikube version: v0.28.2
  - server version: v1.10.0
  - client version: v1.10.0

#### Building the application

	* ./build.sh

#### Installing

The image for the application has been pushed on hub.docker.com: `abhijithg/app:v1`

	* cd app
	* kubectl apply k8s.yaml

#### Running

	$ kubectl apply k8s.yaml
	$ kubectl port-forward service/app 3000:4567 & # or in a different tty
	$ curl localhost:3000/alive # => true

#### URLs exposed via the webserver

|url     | type   | params | desc     |
|:-------|:------:|:------:|:--------:|
| /      | GET    | None   | Index
| /flush | DELETE | None   | Clears the queue
| /alive | GET    | None   | Check if WebServer end-point is accessible
| /ready | GET    | None   | Check if Queue is accessible
| /send  | POST   | None   | Accepts JSON payload and pushes into a queue if schema passes validation

#### TODO

* signal handling
* json logging
