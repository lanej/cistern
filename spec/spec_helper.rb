if ENV["TRAVIS"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require File.expand_path('../../lib/cistern', __FILE__)

Bundler.require(:test)

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true

  if Kernel.respond_to?(:caller_locations)
    require File.expand_path('../../lib/cistern/coverage', __FILE__)
  else
    c.filter_run_excluding(:coverage)
  end
end
