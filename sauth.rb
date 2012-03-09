require 'sinatra'

require_relative 'lib/user'


def generate_cookie 
  require 'securerandom'
  SecureRandom.urlsafe_base64(20)
end




get '/' do
  redirect "/login"
end

get '/login' do
   erb :"login"
end

post '/session' do
  if User.authenticate(params["user"])
    login=params["user"]["login"]
    val_cookie=generate_cookie
    session[:session_id][val_cookie]=login
    response.set_cookie("id_session",val_cookie)
    "Bonjour #{session[:session_id]}"
  end
  
  
end

get '/user/new' do
  erb :"register"
end

post '/user' do
 u = User.new(params["user"])
 if u.save
   redirect "/login"
 else
   erb :"register"
 end
end
