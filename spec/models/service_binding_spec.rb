require 'spec_helper'

describe ServiceBinding do
  describe "template_delete" do
    it "returns policy lines to delete the host" do
      expect(ServiceBinding.template_delete('binding-id')).to include("delete")
      expect(ServiceBinding.template_delete('binding-id')).to include("!host binding-id")
    end
  end
end
