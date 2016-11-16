# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem"s dependencies in cistern.gemspec
gemspec

gem 'appraisal'
gem 'rubocop', '~> 0.44.1'

group :test do
  gem 'guard-rspec', '~> 4.2', require: false
  gem 'guard-bundler', '~> 2.0', require: false
  gem 'pry-nav'
  gem 'rake'
  gem 'rspec', '~> 3.3'
  gem 'listen', '~> 3.0.5'
  gem 'redis-namespace', '~> 1.4', '< 1.5'
  gem 'codeclimate-test-reporter', require: false
end

group :formatters do
  gem 'formatador'
  gem 'awesome_print'
end
