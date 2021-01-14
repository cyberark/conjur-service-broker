require 'spec_helper'
require 'conjur_client'

describe ConjurClient do
  describe "#api" do
    let(:master_url) { "master" }
    let(:follower_url) { "follower" }
    
    before do
      allow(ENV).to receive(:[]).and_call_original

      allow(ENV).to receive(:[]).with('CONJUR_APPLIANCE_URL').and_return(master_url)
      allow(ENV).to receive(:[]).with('CONJUR_FOLLOWER_URL').and_return(follower_url)
    end

    it "returns a Conjur API object" do
      expect(ConjurClient.api).to be_instance_of(Conjur::API)
    end

    it "uses the Conjur Master URL" do
      ConjurClient.api
      expect(Conjur.configuration.appliance_url).to equal(master_url)
    end
  end

  describe "#readonly_api" do
    let(:master_url) { "master" }
    let(:follower_url) { nil }
    
    before do
      allow(ENV).to receive(:[]).and_call_original

      allow(ENV).to receive(:[]).with('CONJUR_APPLIANCE_URL').and_return(master_url)
      allow(ENV).to receive(:[]).with('CONJUR_FOLLOWER_URL').and_return(follower_url)
    end

    it "returns a Conjur API object" do
      expect(ConjurClient.readonly_api).to be_instance_of(Conjur::API)
    end

    it "uses the Conjur Master URL" do
      ConjurClient.readonly_api
      expect(Conjur.configuration.appliance_url).to equal(master_url)
    end

    context "when the follower URL is configured" do
      let(:follower_url) { "follower" }

      it "uses the Conjur Follower URL" do
        ConjurClient.readonly_api
        expect(Conjur.configuration.appliance_url).to equal(follower_url)
      end
    end
  end

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

  describe "version" do
    before do
      allow(ENV).to receive(:[]).and_call_original
    end

    it "uses the default version (5) when the input is an empty string" do
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return("")
      expect(ConjurClient.version).to eq(5)
    end

    it "uses the default version (5) when the input is `nil`" do
      allow(ENV).to receive(:[]).with('CONJUR_VERSION')
      expect(ConjurClient.version).to eq(5)
    end

    it "throws an error when the input is invalid" do
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return("foobar")
      expect { ConjurClient.version }.to raise_error(RuntimeError)
    end

    it "throws an error when given a deprecated version" do
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return("4")
      expect { ConjurClient.version }.to raise_error(RuntimeError)
    end

    it "uses the given version" do
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return("5")
      expect(ConjurClient.version).to eq(5)
    end
  end
end
