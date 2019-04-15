require 'spec_helper'

describe ::ServiceBinding::ConjurV4AppBinding do
  let(:service_id) { "service_id" }
  let(:binding_id) { "binding_id" }
  let(:org_guid) { nil }
  let(:space_guid) { nil }

  let(:service_binding) do
    ::ServiceBinding::ConjurV4AppBinding.new(
      service_id,
      binding_id,
      org_guid,
      space_guid
    )
  end

  describe "#create" do
    let(:host) { double("host") }
    let(:policy_load_response) { double("response") }

    let(:create_result) { service_binding.create }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return('4')

      allow(host).to receive(:exists?).and_return(false)
      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)

      allow_any_instance_of(ConjurClient).to receive(:platform).and_return(nil)
      allow_any_instance_of(::ServiceBinding::ConjurV4AppBinding).to receive(:create_host).and_return("v4_api_key")
    end

    it "generates all hosts in the foundation policy" do
      expect(create_result[:authn_login]).to eq("host/binding_id")
    end

    context "when space context is present" do
      let(:org_guid) {  "org_guid" }
      let(:space_guid) { "space_guid" }

      it "generates all hosts in the foundation policy" do
        expect(create_result[:authn_login]).to eq("host/binding_id")
      end
    end
  end

  describe "#delete" do
    let(:host) { double("host") }

    before do
      allow(host).to receive(:exists?).and_return(true)
      allow(host).to receive(:rotate_api_key)
      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)
    end

    context "when space context is not present" do
      it "uses the Conjur API to load policy to delete the host" do
        expect(host).to receive(:rotate_api_key)

        service_binding.delete
      end
    end
  end
end
