require 'spec_helper'

describe "Cistern::Collection" do
  class SampleService < Cistern::Service
  end

  class Drug < SampleService::Model
    identity :id
    attribute :name
  end

  class Drugs < SampleService::Collection
    model Drug

    def all
      self.load([{id: 1}, {id: 3, name: "tom"}, {id: 2}])
    end
  end

  class Tacs < SampleService::Collection
    service_method :toes
  end

  it "should generate a default collection method" do
    expect(SampleService.new.drugs).not_to be_empty
  end

  it "should allow for a specific collection name" do
    expect(SampleService.new).to     respond_to(:toes)
    expect(SampleService.new).not_to respond_to(:tacs)
  end

  it "should give to_s" do
    collection = Drugs.new
    expect(collection.to_s).not_to eq "[]"
    expect(collection.to_s.gsub(/:[^>]*/,'')).to eq(collection.all.to_s.gsub(/:[^>]*/,''))
  end

  it "should give size and count" do
    expect(Drugs.new.size).to eq(3)
    expect(Drugs.new.count).to eq(3)
  end

  it "should give first" do
    expect(Drugs.new.first).to eq(Drug.new(id: 1))
  end

  it "should give last" do
    expect(Drugs.new.last).to eq(Drug.new(id: 2))
  end

  it "should reject" do
    expect(Drugs.new.reject{|m| m.id == 2}).to eq([Drug.new(id: 1), Drug.new(id: 3)])
  end

  it "should select" do
    expect(Drugs.new.select{|m| m.id == 2}).to eq([Drug.new(id: 2)])
  end

  it "should slice" do
    expect(Drugs.new.slice(0,2)).to eq([Drug.new(id: 1), Drug.new(id: 3, name: "tom")])
  end

  it "should ==" do
    Drugs.new.all == Drugs.new.all
  end
end
