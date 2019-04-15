require 'spec_helper'

describe ServiceBinding do
  describe "#from_hash" do
    let(:service_binding_class) do
       ServiceBinding.from_hash(
         conjur_version: conjur_version,
         enable_space_identity: enable_space_identity
       )
    end

    context "when using Conjur V5" do
      let(:conjur_version) { 5 }

      context "when space host is enabled" do
        let(:enable_space_identity) { true }
        it "returns the correct class" do
          expect(service_binding_class).to be(::ServiceBinding::ConjurV5SpaceBinding)
        end
      end

      context "when space host is disabled" do
        let(:enable_space_identity) { false }
        it "returns the correct class" do
          expect(service_binding_class).to be(::ServiceBinding::ConjurV5AppBinding)
        end
      end
    end

    context "when using Conjur V4" do
      let(:conjur_version) { 4 }

      context "when space host is enabled" do
        let(:enable_space_identity) { true }
        it "raises an error" do
          expect { service_binding_class }.to raise_error(::ServiceBinding::NonExistentServiceBindingClass)
        end
      end

      context "when space host is disabled" do
        let(:enable_space_identity) { false }
        it "returns the correct class" do
          expect(service_binding_class).to be(::ServiceBinding::ConjurV4AppBinding)
        end
      end
    end

    context "when given an invalid version" do
      let(:conjur_version) { 1 }
      let(:enable_space_identity) { false }
      it "raises an error" do
        expect { service_binding_class }.to raise_error(::ServiceBinding::NonExistentServiceBindingClass)
      end
    end
  end
end
