 require 'sinatra'
#require_relative 'lib/user'

get '/' do
  redirect "/login"
end

get '/login' do
   erb :"login"
end

get '/user/new' do
  if params["r"] == "error"
    erb :"register", :locals => {:notice=>"login or password invalid"} # faux
  else
    erb :"register", :locals => {:notice=>""} 
  end
end

post '/user' do
  u = User.new
  u.login=params[:login]
  u.password=params[:password]
  if u.save
    redirect "/login"
  else
    redirect "/user/new?r=error" 
  end
end
