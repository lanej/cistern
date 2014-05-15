require 'spec_helper'

describe 'mock data' do
  class Patient < Cistern::Service
    request :diagnosis
    request :treat

    class Real
      def diagnosis(options={})
      end

      def treat(options={})
      end
    end

    class Mock
      def diagnosis(diagnosis)
        #self.data[:diagnosis] << rand(2) == 0 ? "sick" : "healthy"
        self.data.store(:diagnosis, self.data.fetch(:diagnosis) + [diagnosis])
      end

      def treat(treatment)
        self.data[:treatments] += [treatment]
      end
    end
  end

  shared_examples "mock_data#backend" do |backend, options|
    it "should store mock data" do
      Patient.mock!
      Patient::Mock.store_in(backend, options)
      Patient.reset!

      p = Patient.new
      p.diagnosis("sick")
      expect(p.data[:diagnosis]).to eq(["sick"])

      p.reset!

      expect(p.data[:diagnosis]).to eq([])

      p.treat("healthy")
      expect(p.data[:treatments]).to eq(["healthy"])

      Patient.reset!

      expect(p.data[:treatments]).to eq([])
    end

  end

  context "with a storage backend" do
    describe "Cistern::Data::Hash" do
      include_examples "mock_data#backend", :hash
    end

    describe "Cistern::Data::Redis" do
      include_examples "mock_data#backend", :redis

      context "with an explicit client" do
        before(:each) {
          @other = Redis::Namespace.new("other_cistern", Redis.new)
          @other.set("x", "y")
        }

        include_examples "mock_data#backend", :redis, client: Redis::Namespace.new("cistern", Redis.new)

        after(:each) {
          expect(@other.get("x")).to eq("y")
          @other.del("x")
        }
      end
    end
  end
end
