require 'spec_helper'

class WaitForService < Cistern::Service
  model :wait_for_model, require: false
  collection :wait_for_models, require: false

  class Real
    def initialize(*args)
    end
  end
end

class WaitForService::WaitForModel < Cistern::Model
  identity :id

  attribute :name
end

class WaitForService::WaitForModels < Cistern::Collection
  model WaitForService::WaitForModel

  def get(identity)
    self
  end
end

describe 'Cistern#wait_for' do
  it "should return false if timeout exceeded" do
    Cistern.wait_for(0, 0) { false }.should be_false
  end
end

describe 'Cistern#wait_for!' do
  it "should raise if timeout exceeded" do
    lambda { Cistern.wait_for!(0, 0) { false } }.should raise_exception(Cistern::Timeout)
  end
end

describe 'Cistern::Model#wait_for!' do
  let(:service) { WaitForService.new }
  let(:model)   { service.wait_for_models.new(identity: 1) }

  it "should raise if timeout exceeded" do
    lambda { model.wait_for!(0, 0) { false } }.should raise_exception(WaitForService::Timeout)
  end
end


describe "WaitForModel#timeout" do
  let(:service) { WaitForService.new }
  let(:model)   { service.wait_for_models.new(identity: 1) }

  it "should use service-specific timeout in #wait_for" do
    service.class.timeout = 0.1
    service.class.poll_interval = 0

    elapsed = 0

    timeout(2) do
      lambda do
        model.wait_for! { sleep(0.2); elapsed += 0.2; elapsed > 0.2 }
      end.should raise_exception(WaitForService::Timeout)
    end
  end

  it "should favor explicit timeout" do
    service.class.timeout = 1
    service.class.poll_interval = 0

    elapsed = 0

    timeout(2) do
      lambda do
        model.wait_for!(0.1) { sleep(0.2); elapsed += 0.2; elapsed > 0.2 }
      end.should raise_exception(WaitForService::Timeout)
    end
  end
end
