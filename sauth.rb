 require 'sinatra'


get '/' do
  redirect "/login"
end

get '/login' do
   erb :"login"
end
