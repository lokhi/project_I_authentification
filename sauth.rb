 require 'sinatra'


get '/' do
  redirect "/login"
end

get '/login' do
   erb :"login"
end

get '/register' do
  erb :"register"
end

post '/register' do
  erb :"register"
end
