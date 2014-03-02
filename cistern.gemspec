# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cistern/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Josh Lane"]
  gem.email         = ["me@joshualane.com"]
  gem.description   = %q{API client framework extracted from Fog}
  gem.summary       = %q{API client framework}
  gem.license       = "MIT"
  gem.homepage      = "http://joshualane.com/cistern"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cistern"
  gem.require_paths = ["lib"]
  gem.version       = Cistern::VERSION
end
