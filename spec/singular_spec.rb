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

  it 'should work' do
    expect(Sample.new.sample_singular.name).to eq('amazing')
  end

  describe 'deprecation', :deprecated do
    it 'responds to #service' do
      sample = Sample.new.sample_singular
      expect(sample.service).to eq(sample.cistern)
    end
  end

  it 'should reload' do
    singular = Sample.new.sample_singular
    old_count = singular.count
    expect(singular.count).to eq(old_count)
    expect(singular.reload.count).to be > old_count
  end
end
