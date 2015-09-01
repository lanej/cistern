require 'spec_helper'

describe Cistern do
  class SampleService < Cistern::Service
    class Real
    end
  end

  class SampleService::GetSample < Cistern::Request
    service SampleService

    def real(*args)
      args
    end
  end

  class ShowSamples < Cistern::Request
    service SampleService, method: :list_samples

    def real(*args)
      {"samples" => args}
    end
  end

  it "allows requests to be created in a forward compatible structure" do
    expect(SampleService.new.get_sample("likewhoa")).to   contain_exactly("likewhoa")
    expect(SampleService.new.list_samples("likewhoa")).to eq("samples" => ["likewhoa"])
  end
end
