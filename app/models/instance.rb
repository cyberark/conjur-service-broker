require 'conjur_client'

class Instance
  class << self
    def create instance_id, org_id, space_id
      # Create a new role for the instance_id, add annotations
      # for org and space
    end

    def delete instance_id
      # do nothing
    end
  end
end