require 'spec_helper'

describe Cistern::Associations do
  subject { Class.new(Sample::Model) }

  describe '#associations' do
    before {
      Sample::Associate = Class.new(Sample::Model) do
        identity :id

        belongs_to :association, -> { [] }
        has_many :associates, -> { [] }
      end
    }

    it 'returns a mapping of associations types to names' do
      expect(Sample::Associate.associations).to eq(
        {
          :belongs_to => [:association],
          :has_many => [:associates],
        }
      )
    end
  end

  describe '#belongs_to' do
    it 'returns an associated model' do
      Sample::Associate = Class.new(Sample::Model) do
        identity :id
      end

      subject.class_eval do
        identity :id
        attribute :associate_id

        belongs_to :associate, -> { Sample::Associate.new(id: associate_id) }
      end

      sample = subject.new(id: 1, associate_id: 2)

      belongs_to = Sample::Associate.new(id: 2)

      expect(sample.associate).to eq(belongs_to)
    end
  end

  describe '#has_many' do
    before {
      Sample::Associate = Class.new(Sample::Model) do
        identity :id
      end

      Sample::Associates = Class.new(Sample::Collection) do

        attribute :associate_id

        model Sample::Associate

        def all
          load([{id: associate_id + 1}])
        end
      end

      subject.class_eval do
        identity :id
        attribute :associate_id

        has_many :associates, -> { Sample::Associates.new(associate_id: associate_id) }
      end
    }

    it 'returns associated models' do
      expected = Sample::Associates.new(associate_id: 2).load([{id: 3}])

      expect(subject.new(associate_id: 2).associates.all).to eq(expected)
    end

    it 'accepts models in the writer' do
      model = subject.new(associate_id: 2)
      associates_data = [ { id: 1 }, { id: 2 }]
      associates = Sample::Associates.new.load(associates_data)

      model.associates = [ Sample::Associate.new(id: 1), Sample::Associate.new(id: 2) ]

      expect(model.attributes[:associates]).to eq(associates_data)
      expect(model.associates).to eq(associates)
    end

    it 'accepts raw data in the writer' do
      model = subject.new(associate_id: 2)
      associates_data = [ { id: 1 }, { id: 2 }]
      associates = Sample::Associates.new.load(associates_data)

      model.associates = associates_data

      expect(model.attributes[:associates]).to eq(associates_data)
      expect(model.associates).to eq(associates)
    end
  end
end
