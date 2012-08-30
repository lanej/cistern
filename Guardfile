guard 'rspec', :version => 2, :cli => (ENV["RSPEC_CLI"] || "--color") do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
end

