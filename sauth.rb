require 'sinatra'
require 'active_record'
require 'securerandom'
require_relative 'database'
require_relative 'lib/user'

require_relative 'lib/application'

enable :sessions
set :cookie_manager , Hash.new

def generate_cookie
  SecureRandom.base64
end

helpers do 
  def current_user
    cookie = request.cookies["sauthCookie"]
    if !cookie.nil?
      session["current_user"]=settings.cookie_manager[cookie]
    end
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

get '/' do
  if current_user # A faire avec le before
   "Bonjour #{current_user}"
  else
    redirect "/session/new"
  end
end

get '/session/new' do
   
   erb :"login"
end

post '/session' do
 # if User.authenticate(params["user"])
    login=params["user"]["login"]
    session[:current_user]=login
    cookie=generate_cookie
    settings.cookie_manager[cookie]=login
    response.set_cookie("sauthCookie",:value => cookie,:expires => Time.now+24*60*60) # 1 jour d'expiration
    if login == "admin"
     redirect "/admin"
    else
      redirect "/"
    end
    
  #else
   # erb :"login"
  #end
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


get '/appli/:appli' do
  "Application #{appli}"
end


get '/:appli/session/new' do
  "#{appli} login page"
end

post '/:appli/session' do
 if User.authenticate(params["user"])
    login=params["user"]["login"]
    session[:current_user]=login
    #redirect Application.find_by_name(appli).adresse+params["origin"] 
  end
end


get '/admin' do
  "Administration"
end

get '/admin/users' do
  "List of users"
end

get '/admin/applications' do
  "List of applications"
end

#get 'admin/users/:user/destroy' do
#  u = User.find_by_login(user)
#  u.destroy
#end

#get 'admin/appli/:appli/destroy' do
 # a = Application.find_by_name(appli)
 # a.destroy
#end
