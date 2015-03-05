require 'spec_helper'

describe "Cistern::Request" do
  class SampleService < Cistern::Service
    recognizes :key

    class Real
      attr_reader :service_args

      def initialize(*args)
        @service_args = args
      end
    end
  end

  # @todo Sample::Service.request
  class ListSamples < SampleService::Request
    service_method :list_all_samples

    def real(*args)
      service.service_args + args + ["real"]
    end

    def mock(*args)
      args + ["mock"]
    end
  end

  it "should execute a new-style request" do
    expect(SampleService.new.list_all_samples("sample1")).to eq([{}, "sample1", "real"])
    expect(SampleService::Real.new.list_all_samples("sample2")).to eq(["sample2", "real"])
    expect(SampleService::Mock.new.list_all_samples("sample3")).to eq(["sample3", "mock"])

    # service access
    expect(SampleService.new(:key => "value").list_all_samples("stat")).to eq([{:key => "value"}, "stat", "real"])
  end
end
