require 'spec_helper'

describe "Cistern::Hash" do
  describe "#slice" do
    let(:input) do
      { one: "one", two: "two", three: "three" }
    end

    it "returns a new hash with only the specified keys" do
      expect(Cistern::Hash.slice(input, :one, :two)).to eq({ one: "one", two: "two" })
    end

    it "skips keys that aren't in the original hash" do
      expect(Cistern::Hash.slice(input, :four)).to eq({})
    end
  end

  describe "#except" do
    let(:input) do
      { one: "one", two: "two", three: "three" }
    end

    it "returns a new hash without the specified keys" do
      expect(Cistern::Hash.except(input, :one, :two)).to eq({three: "three"})
    end

    it "skips keys that aren't in the original hash" do
      expect(Cistern::Hash.except(input, :four)).to eq(input)
    end
  end

  describe "#stringify_keys" do
    let(:input) do
      { one: "one", two: "two" }
    end

    it "returns a new hash with stringed keys" do
      expect(Cistern::Hash.stringify_keys(input)).to eq({ "one" => "one", "two" => "two" })
    end

    context "with nested hashes or arrays" do
      let(:input) do
        { hash: { one: "one" }, array: [{ two: "two" }] }
      end

      it "stringifies all of the keys" do
        expect(Cistern::Hash.stringify_keys(input)).to eq({ "hash" => { "one" => "one" }, "array" => [{ "two" => "two" }]})
      end
    end
  end
end
