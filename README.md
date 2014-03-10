# StompPublisher

This is a simple library to synchronously publish STOMP messages. It is designed to be as simple as possible and only supports publishing. It uses non-blocking socket operations to reliably timeout without using hackish thread timeouts.

## Installation

Add this line to your application's Gemfile:

    gem 'stomp_publisher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stomp_publisher

## Usage

```
require 'stomp_publisher'
publisher = StompPublisher.new(
  host: "localhost",
  port: 61613,
  login: "guest",
  passcode: "guest",
  vhost: "/",
  connect_timeout: 0.5,
  read_timeout: 0.25,
  write_timeout: 0.25
)
receipt_id = publisher.publish("myqueue", '{ "hello": "world" }', :"content-type" => "application/json")
publisher.publish("myqueue", "hello", :"custom-header" => "world", :"receipt_id" => "my custom STOMP receipt")
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
