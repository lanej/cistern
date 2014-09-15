require 'spec_helper'

describe "Cistern::Model#dirty" do
  class DirtySpec < Cistern::Model
    identity :id

    attribute :name
    attribute :properties, type: :array

    def save
      merge_attributes(attributes)
    end
  end

  it "should mark a existing record as dirty" do
    model = DirtySpec.new(id: 1, name: "steve")
    expect(model.changed).to be_empty

    expect {
      model.properties = [1]
    }.to change { model.dirty? }.to(true)

    expect(model.changed).to eq(properties: [nil, [1]])
    expect(model.dirty_attributes).to eq(properties: [1])

    expect {
      model.properties = [2]
    }.to change { model.changed }.to(properties: [nil, [2]])
    expect(model.dirty_attributes).to eq(properties: [2])

    expect {
      model.save
    }.to change { model.dirty? }.to(false)

    expect(model.changed).to eq({})
    expect(model.dirty_attributes).to eq({})
  end
end
