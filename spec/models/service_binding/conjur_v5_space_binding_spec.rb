require 'spec_helper'

describe ::ServiceBinding::ConjurV5SpaceBinding do
  let(:service_id) { "service_id" }
  let(:binding_id) { "binding_id" }
  let(:org_guid) { "org_guid" }
  let(:space_guid) { "space_guid" }

  let(:service_binding) do
    ::ServiceBinding::ConjurV5SpaceBinding.new(
      service_id,
      binding_id,
      org_guid,
      space_guid
    )
  end

  describe "#create" do
    let(:create_result) { service_binding.create }

    let(:host) { double("host", exists?: host_exists) }
    let(:host_exists) { true }

    let(:api_key) { "api_key" }
    let(:api_key_variable_id) { "cucumber:variable:#{org_guid}/#{space_guid}/space-host-api-key" }
    let(:api_key_variable) { double("api_key", value: api_key, exists?: api_key_exists) }
    let(:api_key_exists) { true }

    before do
      # Assume V5 by default
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return('5')

      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)

      allow_any_instance_of(Conjur::API).to receive(:resource)
        .with(api_key_variable_id)
        .and_return(api_key_variable)

      allow_any_instance_of(ConjurClient).to receive(:platform).and_return(nil)
    end

    it "returns the space host" do
      expect(create_result[:authn_login]).to eq("host/org_guid/space_guid")
      expect(create_result[:authn_api_key]).to eq(api_key)
    end

    context "when the space host doesn't exist" do
      let(:host_exists) { false }

      it "raises an error" do
        expect { create_result }.to raise_error(::ServiceBinding::HostNotFound)
      end
    end

    context "when the api key variable doesn't exist" do
      let(:api_key_exists) { false }
      it "raises an error" do
        expect { create_result }.to raise_error(::ServiceBinding::ConjurV5SpaceBinding::ApiKeyNotFound)
      end
    end
  end
end
