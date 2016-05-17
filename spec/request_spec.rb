require 'spec_helper'

describe 'Cistern::Request' do
  class RequestService
    include Cistern::Client

    recognizes :key

    class Real
      attr_reader :service_args

      def initialize(*args)
        @service_args = args
      end
    end
  end

  # @todo Sample::Service.request
  class ListSamples < RequestService::Request
    cistern_method :list_all_samples

    def real(*args)
      cistern.service_args + args + ['real']
    end

    def mock(*args)
      args + ['mock']
    end
  end

  it 'should execute a new-style request' do
    expect(RequestService.new.list_all_samples('sample1')).to eq([{}, 'sample1', 'real'])
    expect(RequestService::Real.new.list_all_samples('sample2')).to eq(%w(sample2 real))
    expect(RequestService::Mock.new.list_all_samples('sample3')).to eq(%w(sample3 mock))

    # service access
    expect(RequestService.new(key: 'value').list_all_samples('stat')).to eq([{ key: 'value' }, 'stat', 'real'])
  end

  describe 'deprecation', :deprecated do
    class DeprecatedRequestService
      include Cistern::Client
    end

    it 'responds to #service' do
      class ListDeprecations < DeprecatedRequestService::Request
        service_method :list_deprecations

        def real
          self
        end
      end

      sample = DeprecatedRequestService.new.list_deprecations
      expect(sample.service).to eq(sample.cistern)
    end
  end
end
