require 'spec_helper'

describe ServiceBinding do
  describe "#create" do
    let(:host) { double("host") }
    let(:policy_load_response) { double("response")}

    before do
      # Assume V5 unless otherwise set
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return('5')

      allow(host).to receive(:exists?).and_return(false)
      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)

      allow_any_instance_of(ConjurClient).to receive(:platform).and_return(nil)

      policy_load_response.stub_chain(:created_roles, :values, :first, :[]).and_return("api_key")
    end

    context "when space context is not present" do
      it "generates all hosts in the foundation policy" do
        if ENV['CONJUR_VERSION'] == '5'
          expected_policy = <<~YAML
          - !host
            id: binding_id
          YAML
          expect_any_instance_of(Conjur::API).
            to receive(:load_policy).
            with("root", expected_policy, method: :post
            ).
            and_return(policy_load_response)
        end

        result = ServiceBinding.new("service_id", "binding_id", nil, nil).create
        expect(result[:authn_login]).to eq("host/binding_id")
      end

      context "when the platform is present" do
        before do
          allow(ConjurClient).to receive(:platform).and_return("platform")
        end
        
        it "generates policy that includes the platform annotation" do
          if ENV['CONJUR_VERSION'] == '5'
            expected_policy = <<~YAML
            - !host
              id: binding_id
              annotations:
                platform: true
            YAML
            expect_any_instance_of(Conjur::API).
              to receive(:load_policy).
              with("root", expected_policy, method: :post
              ).
              and_return(policy_load_response)
          end
  
          result = ServiceBinding.new("service_id", "binding_id", nil, nil).create
          expect(result[:authn_login]).to eq("host/binding_id")
        end
      end
    end

    context "when space context is present" do
      subject { ServiceBinding.new("service_id", "binding_id", "org_guid", "space_guid") }

      it "generates hosts within the org/space hierarchy" do
        if ENV['CONJUR_VERSION'] == '5'
          expected_policy = <<~YAML
          - !host
            id: binding_id

          - !grant
            role: !layer
            member: !host binding_id
          YAML
          expect_any_instance_of(Conjur::API).
            to receive(:load_policy).
            with("org_guid/space_guid", expected_policy, method: :post
            ).
            and_return(policy_load_response)
        end

        result = subject.create
        expect(result[:authn_login]).to eq("host/org_guid/space_guid/binding_id")
      end

      context "when using Conjur V4" do
        let(:host) { double("host") }

        before do
           allow(ConjurClient).to receive(:version).and_return(4)
           
           allow(host).to receive(:exists?).and_return(false)
            allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)

          allow_any_instance_of(ServiceBinding).to receive(:create_host_v4).and_return("v4_api_key")
        end

        it "generates all hosts in the foundation policy" do 
          result = subject.create
          expect(result[:authn_login]).to eq("host/binding_id")
        end
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
        if ENV['CONJUR_VERSION'] == '5'
          expected_policy = <<~YAML
          - !delete
            record: !host binding_id
          YAML
          expect_any_instance_of(Conjur::API).
            to receive(:load_policy).
            with("root", expected_policy, method: :patch
            )
        end
        expect(host).to receive(:rotate_api_key)

        ServiceBinding.new("service_id", "binding_id", nil, nil).delete
      end
    end
  end
end
