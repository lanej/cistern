require 'spec_helper'

describe "Cistern::Model" do
  describe "#update" do
    class UpdateSpec < Sample::Model
      identity :id
      attribute :name
      attribute :properties

      def save
        attributes
      end
    end

    it "should merge and save attributes" do
      model = UpdateSpec.new(name: "steve")
      model.save

      expect(model.update(name: "karen")).to eq(name: "karen")
    end
  end

  it "should duplicate a model" do
    class DupSpec < Sample::Model
      identity :id
      attribute :name
      attribute :properties
    end

    model = DupSpec.new(id: 1, name: "string", properties: {value: "something", else: "what"})
    duplicate = model.dup

    expect(duplicate).to eq(model)
    expect(duplicate).to eql(model)

    model.name = "anotherstring"
    expect(duplicate.name).to eq("string")
  end

  context "attribute parsing" do
    class TypeSpec < Sample::Model
      identity :id
      attribute :name, type: :string
      attribute :created_at, type: :time
      attribute :flag, type: :boolean
      attribute :list, type: :array
      attribute :number, type: :integer
      attribute :floater, type: :float
      attribute :butternut_id, squash: ["squash", "id"], type: :integer
      attribute :butternut_type, squash: ["squash", "type"]
      attribute :squash
      attribute :vegetable, aliases: "squash"
      attribute :custom, parser: lambda { |v, _| "X!#{v}" }
      attribute :default, default: "im a squash"

      attribute :same_alias_1, aliases: "nested"
      attribute :same_alias_2, aliases: "nested"

      attribute :same_alias_squashed_1, squash: ["nested", "attr_1"]
      attribute :same_alias_squashed_2, squash: ["nested", "attr_2"]
      attribute :same_alias_squashed_3, squash: ["nested", "attr_2"]
      attribute :adam_attributes, aliases: "attributes"

      def save
        requires :flag
      end
    end

    it "should parse string" do
      expect(TypeSpec.new(name: 1).name).to eq("1")
    end

    it "should handle a 'attributes' aliased attribute" do
      expect(TypeSpec.new(attributes: "x").adam_attributes).to eq("x")
    end

    it "should parse time" do
      time = Time.now
      created_at = TypeSpec.new(created_at: time.to_s).created_at
      expect(created_at).to be_a(Time)
      expect(created_at.to_i).to eq(time.to_i)
    end

    it "should parse boolean" do
      expect(TypeSpec.new(flag: "false").flag).to be_falsey
      expect(TypeSpec.new(flag: "true").flag).to be_truthy
      expect(TypeSpec.new(flag: false).flag).to be_falsey
      expect(TypeSpec.new(flag: true).flag).to be_truthy
      expect(TypeSpec.new(flag: "0").flag).to be_falsey
      expect(TypeSpec.new(flag: "1").flag).to be_truthy
      expect(TypeSpec.new(flag: 0).flag).to be_falsey
      expect(TypeSpec.new(flag: 1).flag).to be_truthy
      expect(TypeSpec.new(flag: false)).not_to be_flag
      expect(TypeSpec.new(flag: true)).to be_flag
    end

    it "should parse an array" do
      expect(TypeSpec.new(list: []).list).to eq([])
      expect(TypeSpec.new(list: "item").list).to eq(["item"])
    end

    it "should parse a float" do
      expect(TypeSpec.new(floater: "0.01").floater).to eq(0.01)
      expect(TypeSpec.new(floater: 0.01).floater).to eq(0.01)
    end

    it "should use custom parser" do
      expect(TypeSpec.new(custom: "15").custom).to eq("X!15")
    end

    it "should squash, cast, alias an attribute and keep a vanilla reference" do
      # vanilla squash
      expect(TypeSpec.new({"squash" => {"id" => "12", "type" => "fred"}}).butternut_type).to eq("fred")
      expect(TypeSpec.new({"squash" => {"id" => "12", "type" => nil}}).butternut_type).to be_nil
      expect(TypeSpec.new({"squash" => nil}).butternut_type).to be_nil

      # composite processors: squash and cast
      expect(TypeSpec.new({"squash" => {"id" => "12", "type" => "fred"}}).butternut_id).to eq(12)
      expect(TypeSpec.new({"squash" => {"id" => nil, "type" => "fred"}}).butternut_id).to be_nil
      expect(TypeSpec.new({"squash" => {"type" => "fred"}}).butternut_id).to be_nil

      # override intermediate processing
      expect(TypeSpec.new({"squash" => {"id" => "12", "type" => "fred"}}).squash).to eq({"id" => "12", "type" => "fred"})

      # alias of override
      expect(TypeSpec.new({"squash" => {"id" => "12", "type" => "fred"}}).vegetable).to eq({"id" => "12", "type" => "fred"})
    end

    it "should set a default value" do
      expect(TypeSpec.new.default).to eq("im a squash")
    end

    it "should override a default value" do
      expect(TypeSpec.new(default: "now im a different squash").default).to eq("now im a different squash")
    end

    context "allowing the same alias for multiple attributes" do
      it "should do so when not squashing" do
        type_spec = TypeSpec.new({"nested" => "bamboo"})
        expect(type_spec.same_alias_1).to eq("bamboo")
        expect(type_spec.same_alias_2).to eq("bamboo")
      end

      it "should do so when squashing" do
        type_spec = TypeSpec.new({"nested" => {"attr_1" => "bamboo", "attr_2" => "panda"}})
        expect(type_spec.same_alias_squashed_1).to eq("bamboo")
        expect(type_spec.same_alias_squashed_2).to eq("panda")
        expect(type_spec.same_alias_squashed_3).to eq("panda")
      end
    end

    it "should slice out unaccounted for attributes" do
      expect(TypeSpec.new({"something" => {"id" => "12"}}).attributes.keys).not_to include("something")
    end

    describe "#requires" do
      it "should raise if attribute not provided" do
        expect { TypeSpec.new({"service" => "fake", "something" => {"id" => "12"}}).save }.to raise_exception(ArgumentError)
      end

      it "should raise if attribute is provided and is nil" do
        expect { TypeSpec.new({"service" => "fake", "custom" => nil}).save }.to raise_exception(ArgumentError)
      end
    end
  end

  context "attribute coverage info collecting", :coverage do
    class CoverageSpec < Sample::Model
      identity :id

      attribute :used, type: :string
      attribute :unused, type: :string
    end

    let!(:obj) { CoverageSpec.new(used: "foo", unused: "bar") }

    before(:each) do
      CoverageSpec.attributes[:used][:coverage_hits] = 0
      expect(obj.used).to eq("foo") # once
      expect(obj.used).to eq("foo") # twice
    end

    it "should store the file path where the attribute was defined" do
      expect(CoverageSpec.attributes[:used][:coverage_file]).to eq(__FILE__)
      expect(CoverageSpec.attributes[:unused][:coverage_file]).to eq(__FILE__)
    end

    it "should store the line number where the attribute was defined" do
      src_lines = File.read(__FILE__).lines

      expect(src_lines[CoverageSpec.attributes[:used][:coverage_line] - 1]).to match(/attribute :used/)
      expect(src_lines[CoverageSpec.attributes[:unused][:coverage_line] - 1]).to match(/attribute :unused/)
    end

    it "should store how many times an attribute's reader is called" do
      expect(CoverageSpec.attributes[:used][:coverage_hits]).to eq(2)
      expect(CoverageSpec.attributes[:unused][:coverage_hits]).to eq(0)
    end
  end
end
