# frozen_string_literal: true

require 'spec_helper'

describe Cistern::Attributes, '#clone_attributes' do
  subject { Class.new(Sample::Model) }

  it 'marshals the source attributes' do
    subject.class_eval do
      attribute :name
      attribute :number
      attribute :serial_number
    end

    model = subject.new(name: 'steve', number: 1, serial_number: 34)

    cloned_attributes = model.clone_attributes

    expect(cloned_attributes).to eq(model.attributes)

    model.number = 3

    expect(cloned_attributes[:number]).to eq(1)
  end

end

describe Cistern::Attributes, '#request_attributes' do
  subject { Class.new(Sample::Model) }

  it 'returns a reverse-aliased attributes hash' do
    subject.class_eval do
      identity :id
      attribute :name, alias: 'sample_name'
    end

    model = subject.new(name: 'steve', id: 1)

    expect(model.request_attributes).to eq(
      'sample_name' => 'steve',
      'id' => 1
    )
  end

  it 'drops duplicates values for multiple aliases' do
    subject.class_eval do
      identity :id
      attribute :name, aliases: ['sample_name', 'other_name']
    end

    model = subject.new(name: 'steve', id: 1)

    expect(model.request_attributes).to eq(
      'sample_name' => 'steve',
      'other_name' => 'steve',
      'id' => 1
    )
  end
end

describe Cistern::Attributes, '#dirty_request_attributes' do
  subject { Class.new(Sample::Model) }

  it 'returns a reverse-aliased attributes hash of dirty attributes only' do
    subject.class_eval do
      identity :id
      attribute :name, alias: 'sample_name'
    end

    model = subject.new
    model.merge_attributes(name: 'steve', id: 1)

    model.name = 'bob'

    expect(model.dirty_request_attributes).to eq(
      'sample_name' => 'bob',
    )
  end

  it 'drops duplicates values for multiple aliases' do
    subject.class_eval do
      identity :id
      attribute :name, aliases: ['sample_name', 'other_name']
    end

    model = subject.new(name: 'steve', id: 1)

    expect(model.request_attributes).to eq(
      'sample_name' => 'steve',
      'other_name' => 'steve',
      'id' => 1
    )
  end
end

describe Cistern::Attributes, 'requires' do
  subject {
    Class.new(Sample::Model) do
      identity :id
      attribute :name, type: :string
      attribute :type
    end
  }

  it 'raises if required attributes are not present' do
    expect {
      subject.new.requires :name
    }.to raise_exception(ArgumentError, /name is required/)

    data = { name: '1' }
    return_value = subject.new(data).requires :name

    expect(return_value).to eq(data)

    expect {
      subject.new.requires :name, :type
    }.to raise_exception(ArgumentError, /name and type are required/)

    data = { name: '1', type: 'sample' }
    return_values = subject.new(data).requires :name, :type
    expect(return_values).to eq(data)
  end

  it 'raises if a required attribute attribute is not present' do
    expect {
      subject.new.requires_one :name, :type
    }.to raise_exception(ArgumentError, /name or type are required/)

    data = { name: '1' }
    return_value = subject.new(data).requires_one :name, :type

    expect(return_value).to eq(data)

    data = { name: '1', type: 'sample' }
    return_values = subject.new(data).requires_one :name, :type
    expect(return_values).to eq(data)
  end
end

describe Cistern::Attributes, 'parsing' do
  subject {
    Class.new(Sample::Model)
  }

  it 'should parse string' do
    subject.class_eval do
      attribute :name, type: :string
    end

    expect(subject.new(name: 1).name).to eq('1')
    expect(subject.new(name: "b").name).to eq('b')
    expect(subject.new(name: nil).name).to eq(nil)
  end

  it "should handle a 'attributes' aliased attribute" do
    subject.class_eval do
      attribute :adam_attributes, aliases: 'attributes'
    end
    expect(subject.new(attributes: 'x').adam_attributes).to eq('x')
  end

  it 'should parse date' do
    subject.class_eval do
      attribute :start_date, type: :date
    end

    date = Date.today
    start_date = subject.new(start_date: date.to_s).start_date
    expect(start_date).to be_a(Date)
    expect(start_date.iso8601).to eq(date.iso8601)
  end

  it 'should parse time' do
    subject.class_eval do
      attribute :created_at, type: :time
    end

    time = Time.now
    created_at = subject.new(created_at: time.to_s).created_at
    expect(created_at).to be_a(Time)
    expect(created_at.to_i).to eq(time.to_i)
  end

  it 'should parse boolean' do
    subject.class_eval do
      attribute :flag, type: :boolean
    end

    ['false', false, '0', 0].each do |falsey|
      expect(subject.new(flag: falsey).flag).to be_falsey
    end

    ['true', true, '1', 1].each do |truthy|
      expect(subject.new(flag: truthy).flag).to be_truthy
    end
  end

  it 'should parse an array' do
    subject.class_eval do
      attribute :list, type: :array
    end

    expect(subject.new(list: []).list).to eq([])
    expect(subject.new(list: 'item').list).to eq(['item'])
  end

  context 'with type integer' do
    before do
      subject.class_eval do
        attribute :int, type: :integer
      end
    end

    [
      ['42.5', 42],
      ['42', 42],
      [42, 42],
      ["4f", 4],
    ].each do |input, output|
      specify("input of #{input.inspect} casts to #{output.inspect}") do
        expect(subject.new(int: input).int).to eq(output)
      end
    end
  end

  it 'should parse a float' do
    subject.class_eval do
      attribute :floater, type: :float
    end

    expect(subject.new(floater: '0.01').floater).to eq(0.01)
    expect(subject.new(floater: 0.01).floater).to eq(0.01)
  end

  it 'should use custom parser' do
    subject.class_eval do
      attribute :custom, parser: lambda { |v, _| "X!#{v}" }
    end

    expect(subject.new(custom: '15').custom).to eq('X!15')
  end

  it 'squashes, casts and aliases an attribute and keeps a vanilla reference' do
    subject.class_eval do
      attribute :butternut_id, squash: %w(squash id), type: :integer
      attribute :butternut_type, squash: %w(squash type)
      attribute :squash
      attribute :vegetable, aliases: 'squash'
    end

    # vanilla squash
    expect(subject.new({ 'squash' => { 'id' => '12', 'type' => 'fred' } }).butternut_type).to eq('fred')
    expect(subject.new({ 'squash' => { 'id' => '12', 'type' => nil } }).butternut_type).to be_nil
    expect(subject.new({ 'squash' => nil }).butternut_type).to be_nil

    # composite processors: squash and cast
    expect(subject.new({ 'squash' => { 'id' => '12', 'type' => 'fred' } }).butternut_id).to eq(12)
    expect(subject.new({ 'squash' => { 'id' => nil, 'type' => 'fred' } }).butternut_id).to be_nil
    expect(subject.new({ 'squash' => { 'type' => 'fred' } }).butternut_id).to be_nil

    # override intermediate processing
    expect(subject.new({ 'squash' => { 'id' => '12', 'type' => 'fred' } }).squash)
      .to eq({ 'id' => '12', 'type' => 'fred' })

    # alias of override
    expect(subject.new({ 'squash' => { 'id' => '12', 'type' => 'fred' } }).vegetable).to eq({ 'id' => '12', 'type' => 'fred' })
  end

  it 'sets a default value' do
    subject.class_eval do
      attribute :default, default: 'im a squash'
    end

    expect(subject.new.default).to eq('im a squash')
  end

  it 'should override a default value' do
    subject.class_eval do
      attribute :default, default: 'im a squash'
    end

    expect(subject.new(default: 'now im a different squash').default).to eq('now im a different squash')
  end

  it 'can skip reader generation' do
    subject.class_eval do
      attribute :default, reader: false
    end

    expect(subject.new).not_to respond_to(:default)
    expect(subject.new).to respond_to(:default=)
  end

  it 'can skip writer generation' do
    subject.class_eval do
      attribute :default, writer: false
    end

    expect(subject.new).to respond_to(:default)
    expect(subject.new).not_to respond_to(:default=)
  end

  context 'allowing the same alias for multiple attributes' do
    before {
      subject.class_eval do
        attribute :same_alias_1, aliases: 'nested'
        attribute :same_alias_2, aliases: 'nested'

        attribute :same_alias_squashed_1, squash: %w(nested attr_1)
        attribute :same_alias_squashed_2, squash: %w(nested attr_2)
        attribute :same_alias_squashed_3, squash: %w(nested attr_2)
      end
    }

    it 'should do so when not squashing' do
      model = subject.new('nested' => 'bamboo')

      expect(model.same_alias_1).to eq('bamboo')
      expect(model.same_alias_2).to eq('bamboo')
    end

    it 'should do so when squashing' do
      model = subject.new('nested' => { 'attr_1' => 'bamboo', 'attr_2' => 'panda' })

      expect(model.same_alias_squashed_1).to eq('bamboo')
      expect(model.same_alias_squashed_2).to eq('panda')
      expect(model.same_alias_squashed_3).to eq('panda')
    end
  end

  it 'should slice out unaccounted for attributes' do
    expect(subject.new({ 'something' => { 'id' => '12' } }).attributes.keys).not_to include('something')
  end
end
