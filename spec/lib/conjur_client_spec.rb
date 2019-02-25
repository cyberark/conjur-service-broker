require 'spec_helper'
require 'conjur_client'

describe ConjurClient do
  describe "login_host_id" do
    context "login is a host" do
      before do
        allow(ENV).
          to receive(:[]).
          with('CONJUR_AUTHN_LOGIN').
          and_return('host/some_host')
      end
      
      it "returns login without 'host/' prefix" do
        expect(ConjurClient.login_host_id).to eq('some_host')
      end
    end

    context "login is not a host" do
      before do
        allow(ENV).
          to receive(:[]).
          with('CONJUR_AUTHN_LOGIN').
          and_return('some_user')
      end
      
      it "returns nil if login is not a host" do
        expect(ConjurClient.login_host_id).to be_nil
      end
    end
  end
  
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

      context "follower url is empty string" do
       let(:follower_url) { '' }

        it "returns follower url" do
          expect(ConjurClient.application_conjur_url).to eq(appliance_url)
        end
      end
    end
  end
end
