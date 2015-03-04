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
    # @todo name
    # name :list_all_samples
    def real(*args)
      service.service_args + args + ["real"]
    end

    def mock(*args)
      args + ["mock"]
    end
  end

  it "should execute a new-style request" do
    expect(SampleService.new.list_samples("sample1")).to eq([{}, "sample1", "real"])
    expect(SampleService::Real.new.list_samples("sample2")).to eq(["sample2", "real"])
    expect(SampleService::Mock.new.list_samples("sample3")).to eq(["sample3", "mock"])

    # service access
    expect(SampleService.new(:key => "value").list_samples("stat")).to eq([{:key => "value"}, "stat", "real"])
  end

  it "should allow setting a specific request name" do
    class DestroySamples < SampleService::Request
      request_name :destroy_some_samples

      def real(*args)
        true
      end
    end

    expect(SampleService.new.destroy_some_samples).to eq(true)
  end

  it "should allow request initialization to be shimmed" do
    class DestroySamples < SampleService::Request
      request_name :destroy_some_samples

      def _real(*args)
        @method = "sparkle"

        real("sunshine")
      end

      def real(name)
        @method + "_#{name}"
      end
    end

    expect(SampleService.new.destroy_some_samples).to eq("sparkle_sunshine")
  end
end
