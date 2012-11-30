require 'spec_helper'

describe "Cistern::Model" do

  it "should duplicate a model" do
    class DupSpec < Cistern::Model
      identity :id
      attribute :name
      attribute :properties
    end

    model = DupSpec.new(id: 1, name: "string", properties: {value: "something", else: "what"})
    duplicate = model.dup

    duplicate.should == model
    duplicate.should_not eql model

    model.name= "anotherstring"
    duplicate.name.should == "string"
  end

  context "attribute parsing" do
    class TypeSpec < Cistern::Model
      identity :id
      attribute :name, type: :string
      attribute :created_at, type: :time
      attribute :flag, type: :boolean
      attribute :list, type: :array
      attribute :number, type: :integer
      attribute :floater, type: :float
      attribute :butternut, type: :integer, aliases: "squash", squash: "id"
      attribute :custom, parser: lambda{|v, opts| "X!#{v}"}
    end

    it "should parse string" do
      TypeSpec.new(name: 1).name.should == "1"
    end

    it "should parse time" do
      time = Time.now
      created_at = TypeSpec.new(created_at: time.to_s).created_at
      created_at.should be_a(Time)
      created_at.to_i.should == time.to_i
    end

    it "should parse boolean" do
      TypeSpec.new(flag: "false").flag.should be_false
      TypeSpec.new(flag: "true").flag.should be_true
      TypeSpec.new(flag: false).flag.should be_false
      TypeSpec.new(flag: true).flag.should be_true
      TypeSpec.new(flag: "0").flag.should be_false
      TypeSpec.new(flag: "1").flag.should be_true
      TypeSpec.new(flag: 0).flag.should be_false
      TypeSpec.new(flag: 1).flag.should be_true
    end

    it "should parse an array" do
      TypeSpec.new(list: []).list.should == []
      TypeSpec.new(list: "item").list.should == ["item"]
    end

    it "should parse a float" do
      TypeSpec.new(floater: "0.01").floater.should == 0.01
      TypeSpec.new(floater: 0.01).floater.should == 0.01
    end

    it "should use custom parser" do
      TypeSpec.new(custom: "15").custom.should == "X!15"
    end

    it "should squash and cast" do
      TypeSpec.new({"squash" => {"id" => "12"}}).butternut.should == 12
    end
  end
end
