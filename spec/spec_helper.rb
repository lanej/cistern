# frozen_string_literal: true

if ENV.key?('COVERAGE')
  require 'simplecov'
  SimpleCov.start
end

require File.expand_path('../../lib/cistern', __FILE__)
Cistern.deprecation_warnings = ENV.key?('DEBUG')

Dir[File.expand_path('../{support,shared,matchers,fixtures}/*.rb', __FILE__)].each { |f| require(f) }

Bundler.require(:test)

RSpec.configure do |rspec|
  if Kernel.respond_to?(:caller_locations)
    require File.expand_path('../../lib/cistern/coverage', __FILE__)
  else
    rspec.filter_run_excluding(:coverage)
  end

  rspec.around(:each, :deprecated) do |example|
    original_value = Cistern.deprecation_warnings?
    Cistern.deprecation_warnings = false
    example.run
    Cistern.deprecation_warnings = original_value
  end
end
