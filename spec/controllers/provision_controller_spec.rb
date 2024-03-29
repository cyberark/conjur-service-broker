require 'spec_helper'


RSpec.describe ProvisionController, type: :request do
  let(:username) { ENV['SECURITY_USER_NAME'] }
  let(:password) { ENV['SECURITY_USER_PASSWORD'] }

  let(:headers) do
    {
      'X-Broker-API-Version' => '2.13',
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    }
  end

  describe 'PUT' do
    let(:legacy_params) do
      {
        service_id: 'c024e536-6dc4-45c6-8a53-127e7f8275ab',
        plan_id: '3a116ac2-fc8b-496f-a715-e9a1b205d05c.community',
        context: {
          platform: 'cloudfoundry'
        },
        organization_guid: 'test_org',
        space_guid: 'test_space'
      }
    end
  
    let(:params) do 
      legacy_params.merge({
        context: {
          organization_guid: 'test_org',
          space_guid: 'test_space'
        }
      })
    end

    before do
      # Assume V5 unless otherwise set
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return('5')
    end

    context 'when context is present' do
      it 'creates the org and space policy' do
        expect_any_instance_of(OrgSpacePolicy).to receive(:create)
        expect_any_instance_of(OrgSpacePolicy).to receive(:ensure_exists)
        expect_any_instance_of(SpaceHostPolicy).to receive(:create)

        put('/v2/service_instances/test_instance', params: params, headers: headers)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.body).to eq("{}")
      end
    end

    context 'when context is not present' do
      it 'does not create the org and space policy' do
        expect_any_instance_of(OrgSpacePolicy).not_to receive(:create)

        put('/v2/service_instances/test_instance', params: legacy_params, headers: headers)

        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("{}")
      end
    end
  end

  describe 'DELETE' do
    let(:params) do 
      {
        service_id: 'c024e536-6dc4-45c6-8a53-127e7f8275ab',
        plan_id: '3a116ac2-fc8b-496f-a715-e9a1b205d05c.community'
      }
    end

    let(:delete_path) { '/v2/service_instances/test_instance'}

    before do
      # Assume V5 unless otherwise set
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CONJUR_VERSION').and_return('5')
    end

    it 'returns with a 200 OK response' do
      delete(delete_path, params: params, headers: headers)

      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("{}")
    end
  end
end
