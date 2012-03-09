require 'sinatra'
require_relative 'lib/user'


get '/' do
  redirect "/login"
end

get '/login' do
   erb :"login"
end

post '/session' do
  if User.authenticate(params["user"])
    login=params["user"]["login"]
    response.set_cookie("user_login",login)
    session[:login]=login
    "Bonjour #{session[:login]}"
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
