require 'sinatra'
require 'active_record'
require 'securerandom'
require 'openssl'
require 'logger'
require_relative 'database'
require_relative 'lib/user'

require_relative 'lib/application'

enable :sessions  

set :cookie_manager , Hash.new
set :logger , Logger.new('log/log.txt', 'daily')

def generate_cookie
  SecureRandom.base64
end

helpers do 
  def current_user
    cookie = request.cookies["sauthCookie"]
    if session["current_user"].nil? && !cookie.nil?
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

before '/appli/new' do
  redirect "/session/new" if !current_user 
end

before '/admin' do
  redirect "/session/new" if !(current_user=="admin")
end

get '/' do
   @u=User.find_by_login(current_user)
   @Dapp=Application.where(:user_id => @u.id)
   @Uapp=Application.list_app_used_by(@u.id)
   erb :"index"
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
    @u=User.new(params["user"])
    erb :"login"
  end
end

get '/session/destroy' do
  disconnect
  redirect '/'
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
  erb :"form_appli"
end

post '/appli' do
  u=User.find_by_login(current_user)
  @a = Application.new(params["appli"].merge("user_id"=>u.id))
  if  @a.save
    redirect "/"
  else
    erb :"form_appli"
  end
end

get '/appli/:appli/destroy' do
   u=User.find_by_login(current_user)
   a=Application.find_by_name(params[:appli])
   if a.user_id == u.id
   	a.destroy
   end
   redirect '/'
end

get '/:appli/session/new' do	
  if current_user	
    redirect to Application.generate_link(params["appli"],current_user,params["origin"],params["secret"])
  else
    @a=Application.find_by_name(params["appli"])
    @or=params["origin"]
    @s=params["secret"]
    erb :"appli_login"
  end
end

post '/:appli/session' do
  settings.logger.info("/"+params["appli"]+"/session => "+params["user"]["login"])
  if @u=User.authenticate(params["user"])
    session["current_user"]=@u.login
    #user use this appli !
    us=Use.new
    us.user_id=@u.id
    us.application_id=Application.find_by_name(params["appli"]).id
    us.save
    redirect to Application.generate_link(params["appli"],@u.login,params["origin"],params["secret"])
  else
    @a=Application.find_by_name(params["appli"])
    erb :"appli_login"
  end
  
end


get '/admin' do
  @u=User.all
  @a=Application.all
  erb :"admin"
end


get '/admin/users/:user/destroy' do
  u = User.find_by_login(params[:user])
  u.destroy
  redirect '/admin'
end

get '/admin/appli/:appli/destroy' do
  a = Application.find_by_name(params[:appli])
  a.destroy
  redirect '/admin'
end
