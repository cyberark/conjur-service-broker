require 'sinatra/base'

class TestApp < Sinatra::Application

  configure do
    set :bind, '0.0.0.0'
  end
  
  get '/' do
    "
      <p>Org Secret: #{ENV['ORG_SECRET']}</p>
      <p>Space Secret: #{ENV['SPACE_SECRET']}</p>
      <p>App Secret: #{ENV['APP_SECRET']}</p>
    "
  end

end
