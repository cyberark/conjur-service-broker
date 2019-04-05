require 'spec_helper'

describe SpaceHostPolicy do
  let(:org_guid) { 'my_org' }
  let(:space_guid) { 'my_space' }
  let(:policy_name) { 'cf' }

  subject { SpaceHostPolicy.new(org_guid, space_guid) }

  before do
    allow(ConjurClient).to receive(:policy).and_return(policy_name)    
    allow(ConjurClient).to receive(:login_host_id).and_return('service-broker')  

    allow(ENV).to receive(:[]).and_call_original
  end

  let(:create_policy_body) do
    <<~YAML
      - !host
        id: space_host

      - !grant
        role: !layer
        member: !host space_host

      - !variable
        id: space_host_api_key
    YAML
  end

  describe "#create" do
    it "loads Conjur policy to create the org and space policy" do
      expect_any_instance_of(Conjur::API).
        to receive(:load_policy).
             with("cf/my_org/my_space", create_policy_body, method: :post)

      subject.create
    end
  end  
end

