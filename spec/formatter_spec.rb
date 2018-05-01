# frozen_string_literal: true

require 'spec_helper'

class Inspector < Sample::Model
  identity :id
  attribute :name

  has_many :employees, -> { Inspectors.new(associate_id: id).all }
  has_many :managers, -> { Inspectors.new(associate_id: nil).all }
end

class Anon < Sample::Model
  attribute :chan
end

class Inspectors < Sample::Collection
  attribute :associate_id

  model Inspector

  def all(options = {})
    merge_attributes(options)
    load([{ id: 1, name: '2', managers: [{ id: 5, name: '5'}]}, { id: 3, name: '4' }, employees: [{ id: 9, name: '8'}]])
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
    name="name",
    employees=nil,
    managers=nil
  >')
  end

  it 'formats a collection' do
    expect(Inspectors.new.all.inspect).to eq('  <Inspectors
    associate_id=nil
    [
      <Inspector
        id=1,
        name="2",
        employees=nil,
        managers=[{"id"=>5, "name"=>"5"}]
      >,
      <Inspector
        id=3,
        name="4",
        employees=nil,
        managers=nil
      >,
      <Inspector
        id=nil,
        name=nil,
        employees=[{"id"=>9, "name"=>"8"}],
        managers=nil
      >
    ]
  >')
  end
end
