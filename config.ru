require 'dotenv/load'
require 'dashing'


configure do
  helpers do    
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  
    def authorized?
      return true unless ENV['USERNAME'] || ENV['PASSWORD']
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['USERNAME'], ENV['PASSWORD']]
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
