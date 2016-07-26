require 'spec_helper'

describe Cistern::Associations do
  subject { Class.new(Sample::Model) }

  describe '#belongs_to' do

    it 'returns an assoicated model' do
      Sample::Associate = Class.new(Sample::Model) do
        identity :id
      end

      subject.class_eval do
        identity :id
        attribute :group_id

        belongs_to :group, -> { Sample::Associate.new(id: group_id) }
      end

      sample = subject.new(id: 1, group_id: 2)

      belongs_to = Sample::Associate.new(id: 2)

      expect(sample.group).to eq(belongs_to)
    end
  end

  describe '#has_many' do
    it 'returns assoicated models' do
      Sample::Associate = Class.new(Sample::Model) do
        identity :id
      end

      Sample::Associates = Class.new(Sample::Collection) do

        attribute :group_id

        model Sample::Associate

        def all
          load([{id: group_id + 1}])
        end
      end

      subject.class_eval do
        identity :id
        attribute :group_id

        has_many :groups, -> { Sample::Associates.new(group_id: group_id) }
      end

      expected = Sample::Associates.new(group_id: 2).load([{id: 3}])

      expect(subject.new(group_id: 2).groups.all).to eq(expected)
    end

    it 'stores data within #attributes'
    it 'accepts raw data in the writer'
    it 'accepts models in the writer'
  end
end
