require 'sinatra'
require 'securerandom'
require 'openssl'
require_relative './lib/crypteencode'

helpers do 
  include CrypteEncode
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

set :port, 8910

enable :sessions

def generate_secret
  SecureRandom.urlsafe_base64
end

get '/' do
 erb :"appli1-index"
end



get '/protected' do
  if params["login"].nil? && params["secret"].nil?
    secret =generate_secret
    session[secret]=Time.now.to_i
    redirect to"http://sauth:4567/appli1/session/new?origin=/protected&secret=#{secret}"
  else
    if session[params["secret"]] && (Time.now.to_i - session[params["secret"]] < 60)
     key=File.read('private.pem')
     @login=decypher(key,params["login"])
     erb :"appli1-protected"
    else
      redirect '/'
    end
  end
end
