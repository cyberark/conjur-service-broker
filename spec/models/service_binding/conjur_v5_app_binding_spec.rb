require 'spec_helper'

describe ::ServiceBinding::ConjurV5AppBinding do
  let(:service_id) { "service_id" }
  let(:binding_id) { "binding_id" }
  let(:org_guid) { nil }
  let(:space_guid) { nil }

  let(:service_binding) do
    ::ServiceBinding::ConjurV5AppBinding.new(
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
      # Assume V5 by default
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return('5')

      allow(host).to receive(:exists?).and_return(false)
      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)

      allow_any_instance_of(ConjurClient).to receive(:platform).and_return(nil)

      policy_load_response.stub_chain(:created_roles, :values, :first, :[]).and_return("api_key")
    end

    context "when space context is not present" do
      it "generates all hosts in the foundation policy" do
        expected_policy = <<~YAML
          - !host
            id: binding_id
        YAML
        expect_any_instance_of(Conjur::API)
          .to receive(:load_policy)
          .with("root", expected_policy, method: :post)
          .and_return(policy_load_response)

        expect(create_result[:authn_login]).to eq("host/binding_id")
      end

      context "when the platform is present" do
        before do
          allow(ConjurClient).to receive(:platform).and_return("platform")
        end

        it "generates policy that includes the platform annotation" do
          expected_policy = <<~YAML
            - !host
              id: binding_id
              annotations:
                platform: true
          YAML

          expect_any_instance_of(Conjur::API)
            .to receive(:load_policy)
            .with("root", expected_policy, method: :post)
            .and_return(policy_load_response)

          expect(create_result[:authn_login]).to eq("host/binding_id")
        end
      end
    end

    context "when space context is present" do
      let(:org_guid) { "org_guid" }
      let(:space_guid) { "space_guid" }

      it "generates hosts within the org/space hierarchy" do
        expected_policy = <<~YAML
          - !host
            id: binding_id

          - !grant
            role: !layer
            member: !host binding_id
        YAML
        expect_any_instance_of(Conjur::API)
          .to receive(:load_policy)
          .with("org_guid/space_guid", expected_policy, method: :post)
          .and_return(policy_load_response)

        expect(create_result[:authn_login]).to eq("host/org_guid/space_guid/binding_id")
      end
    end
  end

  describe "#delete" do
    let(:host) { double("host") }

    let(:service_binding) do
      ::ServiceBinding::ConjurV5AppBinding.new(
        service_id,
        binding_id,
        nil,
        nil
        )
    end

    before do
      allow(host).to receive(:exists?).and_return(true)
      allow(host).to receive(:rotate_api_key)
      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)
    end

    context "when space context is not present" do
      it "uses the Conjur API to load policy to delete the host" do
        expected_policy = <<~YAML
          - !delete
            record: !host binding_id
        YAML
        expect_any_instance_of(Conjur::API)
          .to receive(:load_policy)
          .with("root", expected_policy, method: :patch)

        expect(host).to receive(:rotate_api_key)

        service_binding.delete
      end
    end
  end
end
