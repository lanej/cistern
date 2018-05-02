# frozen_string_literal: true

require 'spec_helper'

describe 'Cistern::Model#dirty' do
  subject do
    Class.new(Sample::Model) do
      identity :id

      attribute :name
      attribute :properties, type: :array

      has_many :many, -> { [] }
      belongs_to :one, -> { true }

      def save
        merge_attributes(attributes)
      end
    end
  end

  it 'marks has_many associations as dirty' do
    model = subject.new(many: [1, 2])
    expect(model.changed).to be_empty
    expect { model.many = [3, 4] }.to change { model.dirty? }.to(true)
    expect(model.changed).to eq(many: [[1, 2], [3, 4]])
  end

  it 'marks belongs_to associations as dirty' do
    model = subject.new(one: 1)
    expect(model.changed).to be_empty
    expect { model.one = 2 }.to change { model.dirty? }.to(true)
    expect(model.changed).to eq(one: [1, 2])
  end

  it 'should mark a existing record as dirty' do
    model = subject.new(id: 1, name: 'steve')
    expect(model.changed).to be_empty

    expect do
      model.properties = [1]
    end.to change { model.dirty? }.to(true)

    expect(model.changed).to eq(properties: [nil, [1]])
    expect(model.dirty_attributes).to eq(properties: [1])

    expect do
      model.properties = [2]
    end.to change { model.changed }.to(properties: [nil, [2]])
    expect(model.dirty_attributes).to eq(properties: [2])

    expect do
      model.save
    end.to change { model.dirty? }.to(false)

    expect(model.changed).to eq({})
    expect(model.dirty_attributes).to eq({})
  end
end
