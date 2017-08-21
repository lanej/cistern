require 'spec_helper'

class Inspector < Sample::Model
  identity :id
  attribute :name
end

class Anon < Sample::Model
  attribute :chan
end

class Inspectors < Sample::Collection
  model Inspector

  def all(options = {})
    merge_attributes(options)
    load([{ id: 1, name: '2' }, { id: 3, name: '4' }])
  end
end

describe Cistern::Formatter::Default do
  before { Cistern.formatter = described_class }

  it 'formats a model' do
    expect(
      Inspector.new(id: 1, name: 'name').inspect
    ).to match(
      /<Inspector:0x[a-z0-9]+> {:id=>1, :name=>\"name\"}/
    )

    Anon.inspect
  end

  it 'formats a collection' do
    expect(
      Inspectors.new.all.inspect
    ).to match(
      /<Inspectors:0x[a-z0-9]+> {} records/
    )
  end
end

describe Cistern::Formatter::AwesomePrint do
  before { Cistern.formatter = described_class }

  it 'formats a model' do
    object = Inspector.new(id: 1, name: 'name')

    expect(object.inspect).to eq(object.ai)
  end

  it 'formats a collection' do
    object = Inspectors.new.all

    expect(object.inspect).to eq(object.ai)
  end
end

describe Cistern::Formatter::Formatador do
  before { Cistern.formatter = described_class }

  it 'formats a model' do
    Cistern.formatter = Cistern::Formatter::Formatador

    expect(Inspector.new(id: 1, name: 'name').inspect).to eq('  <Inspector
    id=1,
    name="name"
  >')
  end

  it 'formats a collection' do
    expect(Inspectors.new.all.inspect).to eq('  <Inspectors
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
  >')
  end
end
