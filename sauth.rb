 require 'sinatra'
require_relative 'lib/user'

get '/' do
  redirect "/login"
end

get '/login' do
   erb :"login"
end

get '/register' do
  erb :"register"
end

post '/user/new' do
  u = User.new
  u.login=params[:login]
  u.password=params[:password]
  if u.save
    redirect "/login"
  else
    redirect "/register?r=error"
  end
end
