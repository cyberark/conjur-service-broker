require 'spec_helper'

# make_bind_request_with_env makes a valid bind request, and for the duration of its run uses the provided
# hash to replace the environment variables in the context that the endpoint is evaluated.
def make_bind_request_with_env(env = {})
  # Setup stubs
  allow(ENV).to receive(:[]).and_call_original
  env.each do |key, value|
    allow(ENV).to receive(:[]).with(key.to_s).and_return(value)
  end

  service_id = SecureRandom.uuid
  binding_id = SecureRandom.uuid
  url = "/v2/service_instances/#{service_id}/service_bindings/#{binding_id}"

  put(url,
      params: {
        service_id: "c024e536-6dc4-45c6-8a53-127e7f8275ab",
        plan_id: "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
        bind_resource: {
          app_guid: "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
        },
        parameters: {
          parameter1: 1,
          parameter2: "foo"
        }
      },
      headers: {
        'X-Broker-API-Version' => '2.13',
        'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(
          ENV['SECURITY_USER_NAME'],
          ENV['SECURITY_USER_PASSWORD'],
          )
      })

  # Clear stubs
  allow(ENV).to receive(:[]).and_call_original
end

# Here it is assumed that the environment already has the environment variables for the happy path,
# so that a call to make_bind_request_with_env is a deviation from the happy path.
RSpec.describe BindController, type: :request do
  it '201 when bind resource' do
    make_bind_request_with_env(
      {
        CONJUR_FOLLOWER_URL: ""
      }
    )

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:created)

    credentials = JSON.parse(response.body)["credentials"]
    expect(credentials["account"]).to eq("cucumber")
    expect(credentials["appliance_url"]).to eq(ENV['CONJUR_APPLIANCE_URL'])
    expect(credentials["authn_login"]).to be_kind_of(String)
    expect(credentials["authn_api_key"]).to be_kind_of(String)
    expect(credentials["version"]).to be_kind_of(Fixnum)
    # TODO: assert valid conjur credentials
  end

  it '500 when bind resource with a bad Conjur URL' do
    make_bind_request_with_env(
      {
        CONJUR_APPLIANCE_URL: "http://badurl.invalid"
      })

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:internal_server_error )
  end

  it '403 when bind resource with a bad Conjur API key' do
    make_bind_request_with_env(
      {
        CONJUR_AUTHN_API_KEY: "bad-api-key"
      })

  expect(response.content_type).to eq("application/json")
  expect(response).to have_http_status(:forbidden)
  end


end
