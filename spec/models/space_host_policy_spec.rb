require 'spec_helper'

describe SpaceHostPolicy do
  let(:org_guid) { 'my_org' }
  let(:space_guid) { 'my_space' }
  let(:policy_name) { 'cf' }

  subject { SpaceHostPolicy.new(org_guid, space_guid) }

  before do
    allow(ConjurClient).to receive(:policy).and_return(policy_name)    
    allow(ConjurClient).to receive(:login_host_id).and_return('cf-service-broker')  

    allow(ENV).to receive(:[]).and_call_original
  end

  let(:create_policy_body) do
    <<~YAML
      - !host

      - !grant
        role: !layer
        member: !host

      - !variable
        id: space-host-api-key

      - !permit
        role: !host /cf-service-broker
        privileges: [read]
        resource: !variable space-host-api-key
    YAML
  end

  describe "#create" do
    let(:policy_load_response) { double("response") }
    
    before do
      policy_load_response.stub_chain(:created_roles, :values, :first, :[]).and_return("api_key")
    end
    
    it "loads Conjur policy to create the org and space policy" do
      allow_any_instance_of(ConjurApiModel).
        to receive(:set_variable)
      
      expect_any_instance_of(Conjur::API).
        to receive(:load_policy).
        with("cf/my_org/my_space", create_policy_body, method: :post).
        and_return(policy_load_response)
      
      subject.create
    end

    it "stores the space host API key" do
      allow_any_instance_of(Conjur::API).
        to receive(:load_policy).
        and_return(policy_load_response)

      expect_any_instance_of(ConjurApiModel).
        to receive(:set_variable).
             with("cf/my_org/my_space/space-host-api-key", an_instance_of(String))

      subject.create
    end
  end  
end

