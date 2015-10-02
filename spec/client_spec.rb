require 'spec_helper'

RSpec.describe "client" do
  context "with specific architecture" do
    it "allows module-based interfaces" do
      class ModuleClient
        include Cistern::Client.with(interface: :module)
      end

      class ModuleClient::ModRequest
        include ModuleClient::Request

        def real(mod)
          9 % mod
        end
      end

      expect(
        ModuleClient.new.mod_request(9)
      ).to eq(0)
    end

    it "allows custom request interface" do
      class AskClient
        include Cistern::Client.with(request: "Ask")
      end

      class AskClient::ModRequest < AskClient::Ask
        def real(mod)
          9 % mod
        end
      end

      expect(
        AskClient.new.mod_request(9)
      ).to eq(0)
    end
  end
end
