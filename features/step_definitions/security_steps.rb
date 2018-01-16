And(/^the environment contains an invalid conjur api key$/) do
  account = ENV['CONJUR_ACCOUNT']
  appliance_url = ENV['CONJUR_APPLIANCE_URL']
  login = ENV['CONJUR_AUTHN_LOGIN']
  api_key = ENV['CONJUR_AUTHN_API_KEY']

  expect{
    Conjur.with_configuration Conjur::Configuration.new(
        account: account,
        appliance_url: appliance_url
    ) do
      Conjur::API.authenticate(login, api_key)
    end
  }.to raise_error(RestClient::Unauthorized)
end
