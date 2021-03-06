# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'damsel/version'

Gem::Specification.new do |spec|
  spec.name          = "damsel"
  spec.version       = Damsel::Version::STRING
  spec.authors       = ["Shawn Catanzarite"]
  spec.email         = ["me@shawncatz.com"]
  spec.description   = %q{simplied creation of DSL's}
  spec.summary       = %q{simplied creation of DSL's}
  spec.homepage      = "https://github.com/shawncatz/damsel"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
