require 'spec_helper'

describe "Cistern::Collection" do
  class SampleCollectionModel < Sample::Model
    identity :id
    attribute :name
  end

  class SampleCollection < Sample::Collection
    model SampleCollectionModel

    def all
      self.load([{id: 1}, {id: 3, name: "tom"}, {id: 2}])
    end
  end

  it "should give to_s" do
    collection = SampleCollection.new
    expect(collection.to_s).not_to eq "[]"
    expect(collection.to_s.gsub(/:[^>]*/,'')).to eq(collection.all.to_s.gsub(/:[^>]*/,''))
  end

  it "should give size and count" do
    expect(SampleCollection.new.size).to eq(3)
    expect(SampleCollection.new.count).to eq(3)
  end

  it "should give first" do
    expect(SampleCollection.new.first).to eq(SampleCollectionModel.new(id: 1))
  end

  it "should give last" do
    expect(SampleCollection.new.last).to eq(SampleCollectionModel.new(id: 2))
  end

  it "should reject" do
    expect(SampleCollection.new.reject{|m| m.id == 2}).to eq([SampleCollectionModel.new(id: 1), SampleCollectionModel.new(id: 3)])
  end

  it "should select" do
    expect(SampleCollection.new.select{|m| m.id == 2}).to eq([SampleCollectionModel.new(id: 2)])
  end

  it "should slice" do
    expect(SampleCollection.new.slice(0,2)).to eq([SampleCollectionModel.new(id: 1), SampleCollectionModel.new(id: 3, name: "tom")])
  end

  it "should ==" do
    SampleCollection.new.all == SampleCollection.new.all
  end
end
