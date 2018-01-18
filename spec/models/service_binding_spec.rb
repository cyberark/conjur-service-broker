require 'spec_helper'

describe ServiceBinding do
  describe "delete" do
    let(:host) { double("host") }
    let(:conjur_api_instance) { double("conjur_api_instance") }

    before do
      allow(host).to receive(:exists?).and_return(true)
      allow(host).to receive(:rotate_api_key)
      allow(conjur_api_instance).to receive(:role).and_return(host)
      allow_any_instance_of(ServiceBinding).to receive(:conjur_api).and_return(conjur_api_instance)
    end
    
    it "uses the Conjur API to load policy to delete the host" do
      expect(conjur_api_instance).
        to receive(:load_policy).
        with("root",
    """
    - !delete
      record: !host binding_id
    """,
        method: :patch
        )
      expect(host).to receive(:rotate_api_key)

      ServiceBinding.new("service_id", "binding_id").delete
    end
  end
end
