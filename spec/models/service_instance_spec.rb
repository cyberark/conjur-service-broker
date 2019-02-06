RSpec.describe ServiceInstance do

  let(:policy_name) { 'cf' }
  let(:instance_id) {'my_instance'}

  let(:organization_guid) { 'my_org' }
  let(:space_guid) { 'my_space' }

  let(:annotations) { {
    'organization-guid' => organization_guid,
    'space-guid' => space_guid
  }}

  let(:resource) { double('resource', exists?: true, annotations: annotations) }

  before do
    allow(ConjurClient).to receive(:policy).and_return(policy_name)    

    allow_any_instance_of(Conjur::API).to receive(:resource)
      .with("#{ConjurClient.account}:cf-service-instance:cf/#{instance_id}")
      .and_return(resource)
  end

  subject { ServiceInstance.new(instance_id) }

  describe "#organization_guid" do
    it 'returns the guid annotation value' do
      expect(subject.organization_guid).to equal(organization_guid)
    end
    context "when the resource doesn't exist" do
      before { allow(resource).to receive(:exists?).and_return(false) }

      it "raises an error" do
        expect {subject.organization_guid}.to raise_error(ServiceInstance::InstanceNotFound)
      end
    end
  end

  describe "#space_guid" do
    it 'returns the guid annotation value' do
      expect(subject.space_guid).to equal(space_guid)
    end
    context "when the resource doesn't exist" do
      before { allow(resource).to receive(:exists?).and_return(false) }

      it "raises an error" do
        expect {subject.space_guid}.to raise_error(ServiceInstance::InstanceNotFound)
      end
    end
  end  
end
