require 'spec_helper'

describe "Cistern::Singular" do
  class SampleSingular < Cistern::Singular
    attribute :name
    attribute :count, type: :number

    def fetch_attributes
      #test that initialize waits for connection to be defined
      raise "missing connection" unless connection

      @counter ||= 0
      @counter += 1
      {name: "amazing", count: @counter}
    end
  end

  it "should work" do
    SampleSingular.new(connection: :fake).name.should == "amazing"
  end

  it "should reload" do
    singular = SampleSingular.new(connection: :fake)
    old_count = singular.count
    singular.count.should == old_count
    singular.reload.count.should > old_count
  end
end
