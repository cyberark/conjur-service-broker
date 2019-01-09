require 'sinatra/base'

class TestApp < Sinatra::Application

  configure do
    set :bind, '0.0.0.0'
  end
  
  get '/' do
    "
      <p>Database Username: #{ENV['DB_USERNAME']}</p>
      <p>Database Password: #{ENV['DB_PASSWORD']}</p>
    "
  end

end
