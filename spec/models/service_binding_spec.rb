require 'spec_helper'

describe ServiceBinding do
  describe "delete" do
    let(:host) { double("host") }
    
    before do
      allow(host).to receive(:exists?).and_return(true)
      allow(host).to receive(:rotate_api_key)
      allow_any_instance_of(Conjur::API).to receive(:role).and_return(host)
    end
    
    it "uses the Conjur API to load policy to delete the host" do
      expect_any_instance_of(Conjur::API).
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
