require 'sinatra'

#require_relative 'lib/user'

require_relative 'lib/application'

enable :sessions


helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

get '/' do
  if current_user
   "Bonjour #{current_user}"
  else
    redirect "/login"
  end
end

get '/login' do
   erb :"login"
end

post '/session' do
  if User.authenticate(params["user"])
    login=params["user"]["login"]
    session[:current_user]=login
    redirect "/"
  end
  erb :"login"
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


get '/appli/new' do
  "<title>Application register</title>"
end

post '/appli' do
  a = Application.new(params["appli"])
  if  a.save
  redirect "/appli/#{params["appli"]["name"]}"
  else
    "<title>Application register</title>"
  end
end
