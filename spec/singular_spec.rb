require 'spec_helper'

describe 'Cistern::Singular' do
  class SampleSingular < Sample::Singular
    attribute :name
    attribute :count, type: :number

    def fetch_attributes
      # test that initialize waits for cistern to be defined
      fail 'missing cistern' unless cistern

      @counter ||= 0
      @counter += 1
      { name: 'amazing', count: @counter }
    end
  end

  describe 'deprecation', :deprecated do
    it 'responds to #service' do
      sample = Sample.new.sample_singular
      expect(sample.service).to eq(sample.cistern)
    end
  end

  it 'reloads on initialize' do
    singular = Sample.new.sample_singular
    expect(singular.name).to eq('amazing')

    expect { singular.reload }.to change(singular, :count).by(1)
  end
end
