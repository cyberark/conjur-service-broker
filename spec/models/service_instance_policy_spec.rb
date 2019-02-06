require 'spec_helper'

describe ServiceInstancePolicy do

  let(:instance_id) { "my_instance" }
  let(:org_guid) { "my_org" }
  let(:space_guid) { "my_space" }
  let(:policy_name) { 'cf' }

  subject { ServiceInstancePolicy.new(instance_id) }   

  before do
    allow(ConjurClient).to receive(:policy).and_return(policy_name)    
    allow(ConjurClient).to receive(:login_host_id).and_return('service-broker')  

    allow(ENV).to receive(:[]).and_call_original
  end

  let(:create_policy_body) do
    <<~YAML
      ---
      - !resource
        id: #{instance_id}
        kind: cf-service-instance
        annotations:
          organization-guid: #{org_guid}
          space-guid: #{space_guid}
      YAML
  end

  describe "#create" do
    it "loads Conjur policy to create the service instance resource" do
      expect_any_instance_of(Conjur::API).
        to receive(:load_policy).
        with(policy_name, create_policy_body, method: :post)

      subject.create(org_guid, space_guid)
    end
  end

  describe "#delete" do

    let(:org_id_search_results) do
      [
        org_policy_resource
      ]
    end

    let(:api) { double('api') }

    let(:delete_instance_policy_body) do
      <<~YAML
      ---
      - !delete
        record:
          !resource
          id: #{instance_id}
          kind: cf-service-instance
      YAML
    end

    before do 
      allow(ConjurClient).to receive(:api).and_return(api)
    end

    it "loads Conjur policy to remove the service instance" do
      expect(api).
        to receive(:load_policy).
        with(policy_name, delete_instance_policy_body, method: :patch)

      subject.delete
    end
  end
end
