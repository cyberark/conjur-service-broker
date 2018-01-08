require 'spec_helper'

describe ServiceBinding do
  describe "delete" do
    let(:host) { double("host") }
    
    before do
      allow(host).to receive(:exists?).and_return(true)
      allow_any_instance_of(Conjur::API).to receive(:resource).and_return(host)
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
      
      ServiceBinding.new("service_id", "binding_id").delete
    end
  end
end
