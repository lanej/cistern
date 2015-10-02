if ENV["TRAVIS"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require File.expand_path('../../lib/cistern', __FILE__)
Dir[File.expand_path("../{support,shared,matchers,fixtures}/*.rb", __FILE__)].each{|f| require(f)}

Bundler.require(:test)

Cistern.deprecation_warnings = false

RSpec.configure do |c|
  if Kernel.respond_to?(:caller_locations)
    require File.expand_path('../../lib/cistern/coverage', __FILE__)
  else
    c.filter_run_excluding(:coverage)
  end
end
