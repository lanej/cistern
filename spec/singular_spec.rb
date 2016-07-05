require 'spec_helper'

describe 'Cistern::Singular' do
  class Settings < Sample::Singular
    attribute :name
    attribute :count, type: :number

    def reload
      # test that initialize waits for cistern to be defined
      fail 'missing cistern' unless cistern

      @counter ||= 0
      @counter += 1
      merge_attributes(name: 'amazing', count: @counter)
    end
  end

  let!(:service) { Sample.new }

  describe 'deprecation', :deprecated do
    it 'responds to #service' do
      sample = service.settings.fetch

      expect(sample.service).to eq(sample.cistern)
    end
  end

  it 'reloads' do
    singular = service.settings(count: 0)

    expect { singular.reload }.to change(singular, :count).by(1)
  end

  it 'updates'
end
