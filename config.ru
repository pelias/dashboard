require 'dashing'

configure do
  if ! ENV['AUTH_TOKEN']
    abort 'Must set AUTH_TOKEN env var. Exiting.'
  end
  set :auth_token, ENV['AUTH_TOKEN']

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
