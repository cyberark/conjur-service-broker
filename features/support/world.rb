require 'rest_client'
require 'conjur-api'

module ServiceBrokerWorld
  def last_json
    raise "No result captured!" unless @response_body
    JSON.pretty_generate(@response_body)
  end
  
  def headers
    @headers ||= { content_type: 'application/json' }
  end

  def basic_auth_username
    'TEST_USER_NAME'
  end

  def basic_auth_password
    'TEST_USER_PASSWORD'
  end
  
  def service_broker_host
    'http://conjur-service-broker:3000'
  end

  def get_json path, options = {}
    response = rest_resource(options)[path].get
    set_result response
  end
  
  def post_json path, body, options = {}
    response = rest_resource(options)[path].post(body)
    set_result response
  end
  
  def put_json path, body = nil, options = {}
    response = rest_resource(options)[path].put(body)
    set_result response
  end

  def delete_json path, options = {}
    response = rest_resource(options)[path].delete
    set_result response
  end

  def patch_json path, body = nil, options = {}
    response = rest_resource(options)[path].patch(body)
    set_result response
  end
  
  def set_result response
    @response = response

    if response.headers[:content_type] =~ /^application\/json/
      @response_body = JSON.parse(response)
      
      if @response_body.respond_to?(:sort!)
        @response_body.sort! unless @response_body.first.is_a?(Hash)
      end
    end
  end

  def try_request
    begin
      yield
    rescue RestClient::Exception
      @exception = $!
      @status = $!.http_code
      set_result @exception.response
    end
  end

  def conjur_authenticate_from_json(response_json)
    account = parse_json(response_json, 'credentials/account')
    appliance_url = parse_json(response_json, 'credentials/appliance_url')
    login = parse_json(response_json, 'credentials/authn_login')
    api_key = parse_json(response_json, 'credentials/authn_api_key')

    Conjur.with_configuration Conjur::Configuration.new(
        account: account,
        appliance_url: appliance_url
    ) do
      Conjur::API.authenticate(login, api_key)
    end
  end

  private

  def rest_resource options
    host = options[:host] || service_broker_host
    args = [ host ]
    args << Hash.new if args.length == 1
    args.last[:headers] ||= {}
    args.last[:headers].merge(headers) if headers
    RestClient::Resource.new(*args).tap do |request|
      headers.each do |k,v|
        request.headers[k] = v
      end
      
      request.options[:user] = options[:user] || basic_auth_username
      request.options[:password] = options[:password] || basic_auth_password
    end
  end
end

World(ServiceBrokerWorld)
