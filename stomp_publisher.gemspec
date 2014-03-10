# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stomp_publisher/version'

Gem::Specification.new do |spec|
  spec.name          = "stomp_publisher"
  spec.version       = StompPublisher::VERSION
  spec.authors       = ["Brian Abreu"]
  spec.email         = ["brian@nutsonline.com"]
  spec.description   = %q{A simple library for publishing messages via the STOMP protocol}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "tcp_timeout"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
