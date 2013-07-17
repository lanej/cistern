require 'spec_helper'

describe "Cistern::Collection" do
  class SampleCollectionModel < Cistern::Model
    identity :id
    attribute :name
  end
  class SampleCollection < Cistern::Collection
    model SampleCollectionModel

    def all
      self.load([{id: 1}, {id: 3, name: "tom"}, {id: 2}])
    end
  end

  it "should give to_s" do
    collection = SampleCollection.new
    collection.to_s.should_not eq "[]"
    collection.to_s.gsub(/:[^>]*/,'').should == collection.all.to_s.gsub(/:[^>]*/,'')
  end

  it "should give size and count" do
    SampleCollection.new.size.should == 3
    SampleCollection.new.count.should == 3
  end

  it "should give first" do
    SampleCollection.new.first.should == SampleCollectionModel.new(id: 1)
  end

  it "should give last" do
    SampleCollection.new.last.should == SampleCollectionModel.new(id: 2)
  end

  it "should reject" do
    SampleCollection.new.reject{|m| m.id == 2}.should == [SampleCollectionModel.new(id: 1), SampleCollectionModel.new(id: 3)]
  end

  it "should select" do
    SampleCollection.new.select{|m| m.id == 2}.should == [SampleCollectionModel.new(id: 2)]
  end

  it "should slice" do
    SampleCollection.new.slice(0,2).should == [SampleCollectionModel.new(id: 1), SampleCollectionModel.new(id: 3, name: "tom")]
  end

  it "should ==" do
    SampleCollection.new.all == SampleCollection.new.all
  end
end
