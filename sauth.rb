require 'sinatra'
require 'active_record'
require 'securerandom'
require 'openssl'
require 'logger'
require_relative 'database'
require_relative 'lib/user'

require_relative 'lib/application'

#enable :sessions  

set :cookie_manager , Hash.new
set :logger , Logger.new('log/log.txt', 'daily')

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

before '/' do
  redirect "/session/new" if !current_user 
end


get '/' do
   "Hello #{current_user}"
end

get '/session/new' do
   
   erb :"login"
end

post '/session' do
  settings.logger.info("/session => "+params["user"]["login"])
  if User.authenticate(params["user"])
    login=params["user"]["login"]
    session["current_user"]=login
    cookie=generate_cookie
    settings.cookie_manager[cookie]=login
    response.set_cookie("sauthCookie",:value => cookie,:expires => Time.now+24*60*60) # 1 jour d'expiration
    if login == "admin"
     redirect "/admin"
    else
      redirect "/"
    end
  else
    erb :"login"
  end
end

get '/user/new' do
  erb :"register"
end

post '/user' do
 @u = User.new(params["user"])
 if @u.save
   redirect "/session/new"
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
  if current_user	
    blogin = Application.appli_crypte_encode(params["appli"],current_user)
    app=Application.find_by_name(params["appli"])
    redirect to app.adresse+params["origin"]+"?secret="+params["secret"]
  else
    "#{appli} login page"
  end
end

post '/:appli/session' do
  settings.logger.info("/"+params["appli"]+"/session => "+params["user"]["login"])
  if u=User.authenticate(params["user"])
    session["current_user"]=u.login
    blogin = Application.appli_crypte_encode(params["appli"],u.login)
    #Application.utilisation(u.login,params["appli"])
    app=Application.find_by_name(params["appli"])
    redirect to app.adresse+params["origin"]+"?secret="+params["secret"]
  else
    "#{appli} login page"
  end
  
end


get '/admin' do

  "Administration List of applications List of users"  
end


get '/admin/users/:user/destroy' do
  u = User.find_by_login(params[:user])
  u.destroy
end

get '/admin/appli/:appli/destroy' do
  a = Application.find_by_name(params[:appli])
  a.destroy
end
