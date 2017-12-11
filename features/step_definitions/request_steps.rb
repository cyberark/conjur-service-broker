When(/^I get "([^"]*)" with basic auth username="([^"]*)" password="([^"]*)"$/) do |path, username, password|

  begin
    @response = RestClient::Resource.new(service_broker_host, :user => username, :password => password)["#{path}"].get
  rescue RestClient::ExceptionWithResponse => err
    @response = err.response
  end

  if @response.headers[:content_type] =~ /^application\/json/
    @result = JSON.parse @response.body
  else
    @result = @response.body
  end
end

When(/^I get "([^"]*)"$/) do |path|
  step 'I get "%s" with basic auth username="%s" password="%s"' % [path, 'TEST_USER_NAME', 'TEST_USER_PASSWORD']
end

When(/^I get "([^"]*)" with correct basic auth credentials$/) do |path|
  step 'I get "%s" with basic auth username="%s" password="%s"' % [path, 'TEST_USER_NAME', 'TEST_USER_PASSWORD']
end

When(/^I get "([^"]*)" with incorrect basic auth credentials$/) do |path|
  step 'I get "%s" with basic auth username="%s" password="%s"' % [path, 'INCORRECT_USER_NAME', 'INCORRECT_USER_PASSWORD']
end
