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
    expect(SampleSingular.new(connection: :fake).name).to eq("amazing")
  end

  it "should reload" do
    singular = SampleSingular.new(connection: :fake)
    old_count = singular.count
    expect(singular.count).to eq(old_count)
    expect(singular.reload.count).to be > old_count
  end
end
