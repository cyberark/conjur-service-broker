require 'spec_helper'
require 'conjur_client'

describe ConjurClient do
  describe 'application_conjur_url' do
    let(:appliance_url) { 'http://conjur-master' }

    before do
      allow(ENV).
        to receive(:[]).
        with('CONJUR_FOLLOWER_URL').
        and_return(nil)
      
      allow(ENV).
        to receive(:[]).
        with('CONJUR_APPLIANCE_URL').
        and_return(appliance_url)
    end
    
    context "no follower url is specified" do
      it "returns appliance url" do
        expect(ConjurClient.application_conjur_url).to eq(appliance_url)
      end
    end

    context "follower url is specified" do
      let(:follower_url) { 'http://conjur-follower' }
      
      before do
        allow(ENV).
          to receive(:[]).
          with('CONJUR_FOLLOWER_URL').
          and_return(follower_url)
      end
      
      it "returns follower url" do
        expect(ConjurClient.application_conjur_url).to eq(follower_url)
      end
    end
  end
end
