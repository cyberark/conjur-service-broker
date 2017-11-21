When(/^I get "([^"]*)""$/) do |path|

  begin
    @response = RestClient::Resource.new(service_broker_host)["#{path}"].get
  rescue RestClient::ExceptionWithResponse => err
    @response = err.response
  end

  if @response.headers[:content_type] =~ /^application\/json/
    @result = JSON.parse @response.body
  else
    @result = @response.body
  end
end
