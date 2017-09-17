# frozen_string_literal: true

require 'spec_helper'

describe 'Cistern::Request' do
  before {
    Sample.class_eval do
      recognizes :key
    end

    Sample::Real.class_eval do
      attr_reader :service_args

      def initialize(*args)
        @service_args = args
      end
    end
  }

  describe '#cistern_method' do
    it 'remaps the client request method' do
      class ListSamples < Sample::Request
        cistern_method :list_all_samples
      end

      expect(Sample.new).to respond_to(:list_all_samples)
      expect(Sample.new).not_to respond_to(:list_samples)
    end
  end

  it 'calls the appropriate method' do
    class GetSamples < Sample::Request
      def real(*args)
        cistern.service_args + args + ['real']
      end

      def mock(*args)
        args + ['mock']
      end
    end

    expect(Sample.new.get_samples('sample1')).to eq([{}, 'sample1', 'real'])
    expect(Sample::Real.new.get_samples('sample2')).to eq(%w(sample2 real))
    expect(Sample::Mock.new.get_samples('sample3')).to eq(%w(sample3 mock))

    # service access
    expect(Sample.new(key: 'value').get_samples('stat')).to eq([{ key: 'value' }, 'stat', 'real'])
  end

  describe 'deprecation', :deprecated do
    it 'calls _mock and _real if present' do
      class Sample::ListDeprecations < Sample::Request
        def _mock
          :_mock
        end

        def real
          :real
        end
      end

      actual = Sample.new.list_deprecations
      expect(actual).to eq(:real)

      Sample.mock!

      actual = Sample.new.list_deprecations
      expect(actual).to eq(:_mock)
    end

    it 'responds to #service' do
      class Sample::ListDeprecations < Sample::Request
        def real
          self
        end
      end

      sample = Sample.new.list_deprecations
      expect(sample.service).to eq(sample.cistern)
    end
  end
end
