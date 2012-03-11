require 'sinatra'
require 'securerandom'


enable :sessions



def generate_secret 
  SecureRandom.urlsafe_base64
end

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end


get '/' do
 "Application"
end



get '/protected' do
  secret=generate_secret
  session["secret"]={secret=> Time.now.to_i}
  redirect "http://sauth/appli1/session/new?origin=/protected&secret=#{secret}"
end
