require 'spec_helper'

describe ProvisionController, :type => :controller do
  describe '#put' do
    def provision_put(instance_id, space_guid)
      allow_any_instance_of(ProvisionController).to receive(:instance_id) { instance_id }
      allow_any_instance_of(ProvisionController).to receive(:space_guid) { space_guid }

      put :put
    end

    context 'standard provision' do
      it "sets a single instance/space map" do
        provision_put('sample_instance_id', 'sample_space_guid')
        expect(response).to be_ok
        expect(@@instance_id_to_space_guid).to have_key['sample_instance_id']
        expect(@@instance_id_to_space_guid['sample_instance_id']).to eq 'sample_space_guid'
      end

      it "sets multiple instance/space maps" do
        put :put, instance_id: 'original_instance_id', space_guid: 'original_space_guid'
        expect(response).to be_ok
        put :put, instance_id: 'new_instance_id', space_guid: 'new_space_guid'
        expect(response).to be_ok
        expect(@@instance_id_to_space_guid).to have_key['original_instance_id']
        expect(@@instance_id_to_space_guid['original_instance_id']).to eq 'original_space_guid'
        expect(@@instance_id_to_space_guid).to have_key['new_instance_id']
        expect(@@instance_id_to_space_guid['new_instance_id']).to eq 'new_space_guid'
      end
    end
  end
end
