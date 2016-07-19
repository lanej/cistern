RSpec.configure do |config|
  config.before(:each) {
    Object.send(:remove_const, :Sample) if Object.constants.include?(:Sample)
    class Sample; include Cistern::Client; end
  }
end

class Sample; include Cistern::Client; end
