require 'dashing'

configure do
  abort 'Must set AUTH_TOKEN env var. Exiting.' unless ENV['AUTH_TOKEN']

  set :auth_token,   ENV['AUTH_TOKEN']
  set :history_file, ENV['HISTORY_FILE_PATH'] || ENV['HOME'] + '/.history.yml'

  if File.exist?(settings.history_file)
    set history: YAML.load_file(settings.history_file)
  else
    set history: {}
  end

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
