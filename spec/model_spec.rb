require 'spec_helper'

describe 'Cistern::Model' do
  describe '#update' do
    class UpdateSpec < Sample::Model
      identity :id
      attribute :name
      attribute :properties

      def save
        dirty_attributes
      end
    end

    it 'should merge and save dirty attributes' do
      model = UpdateSpec.new(name: 'steve')
      model.save

      expect(model.update(name: 'karen')).to eq(name: 'karen')
    end
  end

  context '#new_record?' do
    it 'does not require identity' do
      identity_less = Class.new(Sample::Model)

      expect(identity_less.new.new_record?).to eq(true)
    end

    it 'is false if identity is set' do
      identity_full = Class.new(Sample::Model) {
        identity :id
      }

      expect(identity_full.new.new_record?).to eq(true)
      expect(identity_full.new(id: 1).new_record?).to eq(false)
    end
  end

  it 'should set singular resource service method' do
    class ModelService
      include Cistern::Client
    end

    class ModelService::Jimbob < ModelService::Model
    end

    expect(ModelService.new).to respond_to(:jimbob)
    expect(ModelService.new.jimbob).to be_a(ModelService::Jimbob)
  end

  it 'should set specific singular resource service method' do
    class SpecificModelService
      include Cistern::Client
    end

    class SpecificModelService::Jimbob < SpecificModelService::Model
      cistern_method :john_boy
    end

    expect(SpecificModelService.new).not_to respond_to(:jimbob)
    expect(SpecificModelService.new).to respond_to(:john_boy)
    expect(SpecificModelService.new.john_boy).to be_a(SpecificModelService::Jimbob)
  end

  it 'should duplicate a model' do
    class DupSpec < Sample::Model
      identity :id
      attribute :name
      attribute :properties
    end

    model = DupSpec.new(id: 1, name: 'string', properties: { value: 'something', else: 'what' })
    duplicate = model.dup

    expect(duplicate).to eq(model)
    expect(duplicate).to eql(model)

    model.name = 'anotherstring'
    expect(duplicate.name).to eq('string')
  end

  describe 'deprecation', :deprecated do
    class DeprecatedModelService
      include Cistern::Client
    end

    it 'responds to #service' do
      class Deprecation < DeprecatedModelService::Model
        service_method :deprecator
      end

      sample = DeprecatedModelService.new.deprecator
      expect(sample.service).to eq(sample.cistern)
    end
  end
end
