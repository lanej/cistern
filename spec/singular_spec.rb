require 'spec_helper'

describe 'Cistern::Singular' do
  class Settings < Sample::Singular
    attribute :name, type: :string
    attribute :count, type: :number

    def save
      result = @@settings = attributes.merge(dirty_attributes)

      merge_attributes(result)
    end

    def get
      settings = @@settings ||= {}
      settings[:count] ||= 0
      settings[:count] += 1

      merge_attributes(settings)
    end
  end

  let!(:service) { Sample.new }

  describe 'deprecation', :deprecated do
    it 'responds to #service' do
      sample = service.settings.get

      expect(sample.service).to eq(sample.cistern)
    end
  end

  it 'reloads' do
    singular = service.settings(count: 0)

    expect { singular.reload }.to change(singular, :count).by(1)
  end

  it 'updates' do
    service.settings.update(name: 6)
    expect(service.settings.get.name).to eq('6')
  end
end
