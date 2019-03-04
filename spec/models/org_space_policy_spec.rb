require 'spec_helper'

describe OrgSpacePolicy do

  let(:org_guid) { "my_org" }
  let(:space_guid) { "my_space" }
  let(:policy_name) { 'cf' }

  subject { OrgSpacePolicy.new(org_guid, space_guid) }   

  before do
    allow(ConjurClient).to receive(:policy).and_return(policy_name)    
    allow(ConjurClient).to receive(:login_host_id).and_return('service-broker')  

    allow(ENV).to receive(:[]).and_call_original
  end

  let(:create_policy_body) do
    <<~YAML
      ---
      - !policy
        id: #{org_guid}
        body:
          - !layer

          - !policy
            id: #{space_guid}
            body:
              - !layer

          - !grant
            role: !layer
            member: !layer #{space_guid}
      YAML
  end

  describe "#create" do
    it "loads Conjur policy to create the org and space policy" do
      expect_any_instance_of(Conjur::API).
        to receive(:load_policy).
        with(policy_name, create_policy_body, method: :post)

      subject.create
    end
  end

  describe "#ensure_exists" do
    let(:existent_resource) { double("existent", exists?: true) }
    let(:nonexistent_resource) { double("non-existent", exists?: false) }
  
    before do

      # By default, assume all resources exist
      allow_any_instance_of(Conjur::API)
        .to receive(:resource)
        .with(any_args)
        .and_return(existent_resource)
    end

    context "when resources already exist" do
      it "does not raise an error" do
        expect { subject.ensure_exists}.not_to raise_error
      end
    end

    context "when org policy doesn't exist" do
      before do
        allow_any_instance_of(Conjur::API)
          .to receive(:resource)
          .with("cucumber:policy:#{policy_name}/#{org_guid}").
          and_return(nonexistent_resource)
      end

      it "raises an error" do
        expect { subject.ensure_exists }.to raise_error(OrgSpacePolicy::OrgPolicyNotFound)
      end
    end

    context "when space policy doesn't exist" do
      before do
        allow_any_instance_of(Conjur::API)
          .to receive(:resource)
          .with("cucumber:policy:#{policy_name}/#{org_guid}/#{space_guid}")
          .and_return(nonexistent_resource)
      end

      it "raises an error" do
        expect { subject.ensure_exists }.to raise_error(OrgSpacePolicy::SpacePolicyNotFound)
      end
    end

    context "when space layer doesn't exist" do
      before do
        allow_any_instance_of(Conjur::API)
          .to receive(:resource)
          .with("cucumber:layer:#{policy_name}/#{org_guid}/#{space_guid}")
          .and_return(nonexistent_resource)
      end

      it "raises and error" do
        expect { subject.ensure_exists }.to raise_error(OrgSpacePolicy::SpaceLayerNotFound)
      end
    end
  end
end
