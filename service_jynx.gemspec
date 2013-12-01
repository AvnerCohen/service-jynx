# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_jynx/version'

Gem::Specification.new do |spec|
  spec.name          = "service_jynx"
  spec.version       = ServiceJynx::VERSION
  spec.authors       = ["Avner Cohen"]
  spec.email         = ["israbirding@gmail.com"]
  spec.summary       = %q{Use errors count over sliding windows to block calls to an external service or method, or whatever.}
  spec.description   = %q{Use errors count over sliding windows to block calls to an external service or method, or whatever.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

end
