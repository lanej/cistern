require 'spec_helper'

RSpec.describe 'client' do
  context 'with specific architecture' do
    it 'allows module-based interfaces' do
      class ModuleClient
        include Cistern::Client.with(interface: :module)
      end

      class ModuleClient::Shoot
        include ModuleClient::Request

        def real(mod)
          mod % 9
        end
      end

      class ModuleClient::Moon
        include ModuleClient::Model

        identity :on

        def save
          identity % 3
        end
      end

      class ModuleClient::Moons
        include ModuleClient::Collection

        model ModuleClient::Moon
      end

      expect(
        ModuleClient.new.shoot(12)
      ).to eq(3)

      expect(ModuleClient.collections).to contain_exactly(ModuleClient::Moons)
      expect(ModuleClient.models).to contain_exactly(ModuleClient::Moon)
      expect(ModuleClient.requests).to contain_exactly(ModuleClient::Shoot)

      expect(
        ModuleClient.new.moons.new(on: 5).save
      ).to eq(2)
    end

    it 'allows custom model interface' do
      class AskClient
        include Cistern::Client.with(model: 'Ask', interface: :module)
      end

      class AskClient::Model
        include AskClient::Ask

        identity :id

        def save
          9 % identity
        end
      end

      expect(
        AskClient.new.model(id: 9).save
      ).to eq(0)
    end
  end
end
