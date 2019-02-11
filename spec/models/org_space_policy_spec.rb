require 'spec_helper'

describe OrgSpacePolicy do

  describe "#ensure_exists" do
    let(:existent_resource) { double("existent") }
    let(:nonexistent_resource) { double("non-existent") }

    subject { OrgSpacePolicy.new("org_id", "space_id") }
    
    before do
      allow(existent_resource).to receive(:exists?).and_return(true)
      allow(nonexistent_resource).to receive(:exists?).and_return(false)

      # By default, assume all resources exist
      allow_any_instance_of(Conjur::API)
        .to receive(:resource)
        .with(any_args)
        .and_return(existent_resource)
    end

    context "when resources already exist" do
      it "does nothing" do
        subject.ensure_exists
      end
    end

    context "when org policy doesn't exist" do
      before do
        allow_any_instance_of(Conjur::API)
          .to receive(:resource)
          .with('cucumber:policy:org_id').
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
          .with('cucumber:policy:org_id/space_id')
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
          .with('cucumber:layer:org_id/space_id')
          .and_return(nonexistent_resource)
      end

      it "raises and error" do
        expect { subject.ensure_exists }.to raise_error(OrgSpacePolicy::SpaceLayerNotFound)
      end
    end
  end
end
