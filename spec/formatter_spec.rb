require 'spec_helper'

class Inspector < Cistern::Model
  identity :id
  attribute :name
end

class Anon < Cistern::Model
  attribute :chan
end

class Inspectors < Cistern::Collection
  model Inspector

  def all(options={})
    merge_attributes(options)
    self.load([{id: 1, name: "2"},{id: 3, name: "4"}])
  end
end

describe Cistern::Formatter::Default do
  before { Cistern.formatter = described_class }

  it "formats a model" do
    expect(
      Inspector.new(id: 1, name: "name").inspect
    ).to match(
      /<Inspector:0x[a-z0-9]+> {:id=>1, :name=>\"name\"}/
    )

    Anon.inspect
  end

  it "formats a collection" do
    expect(
      Inspectors.new.all.inspect
    ).to match(
      /<Inspectors:0x[a-z0-9]+> {} records/
    )
  end
end

describe Cistern::Formatter::AwesomePrint do
  before { Cistern.formatter = described_class }

  it "formats a model" do
    expect(
      Inspector.new(id: 1, name: "name").inspect
    ).to match(
      /(?x-mi:\#<Inspector:0x[0-9a-f]+>\ {\n\ \ \ \ \ \ :id\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[1;34m1\x1B\[0m,\n\ \ \ \ :name\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[0;33m"name"\x1B\[0m\n})/
    )
  end

  it "formats a collection" do
    expect(Inspectors.new.all.inspect).to match(/Inspectors\s+{.*}$/m) # close enough
  end
end

describe Cistern::Formatter::Formatador do
  before { Cistern.formatter = described_class }

  it "formats a model" do
    Cistern.formatter = Cistern::Formatter::Formatador

    expect(Inspector.new(id: 1, name: "name").inspect).to eq(%q{  <Inspector
    id=1,
    name="name"
  >})
  end

  it "formats a collection" do
    expect(Inspectors.new.all.inspect).to eq(%q{  <Inspectors
    [
      <Inspector
        id=1,
        name="2"
      >,
      <Inspector
        id=3,
        name="4"
      >
    ]
  >})
  end
end
