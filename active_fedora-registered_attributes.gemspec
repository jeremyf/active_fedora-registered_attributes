# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_fedora/registered_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "active_fedora-registered_attributes"
  spec.version       = ActiveFedora::RegisteredAttributes::VERSION
  spec.authors       = ["Jeremy Friesen"]
  spec.email         = ["jeremy.n.friesen@gmail.com"]
  spec.description   = %q{An ActiveFedora extension for registring attributes}
  spec.summary       = %q{An ActiveFedora extension for registring attributes}
  spec.homepage      = "http://github.com/jeremyf/active_fedora-registered_attributes"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "active-fedora", ">= 6.4"
  spec.add_dependency "active_attr", "~> 0.8.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
