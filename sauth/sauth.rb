require 'sinatra'
require 'active_record'
require 'securerandom'
require 'openssl'
require 'logger'
require_relative 'database'
require_relative 'lib/user'
require_relative 'lib/application'

use Rack::Session::Cookie, :key => 'rack.session', :expire_after => 86400

set :logger , Logger.new('log/log.txt', 'daily')

def generate_cookie
  SecureRandom.base64
end

helpers do 
  def current_user
    session["current_user"]
  end
  
  def cUser 
    User.find_by_login(current_user)
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

before '/appli/:appli/*' do
 redirect "/session/new" if (Application.find_by_name(params["appli"])==nil)
end

get '/' do
   @u=current_user
   @Dapp=Application.where(:user_id => @u.id)
   @Uapp=Application.list_app_used_by(@u.id)
   if(current_user.admin?)
     @user=User.all
     @a=Application.all
     erb :"admin"
   else
    erb :"index"
   end
end

get '/session/new' do
   erb :"login"
end

post '/session' do
  settings.logger.info("/session => "+params["user"]["login"]) unless ENV['RACK_ENV']=='test'
  if session["current_user"]=User.authenticate(params["user"])
    redirect "/"
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

get '/user/:user/destroy' do
  if current_user.admin?
    u = User.find_by_login(params[:user])
    u.destroy unless u.nil?
    redirect '/'
  end
end



get '/appli/new' do
  erb :"form_appli"
end

post '/appli' do
  u=current_user
  @a = Application.new(params["appli"].merge("user_id"=>u.id))
  if  @a.save
    redirect "/"
  else
    erb :"form_appli"
  end
end

get '/appli/:appli/destroy' do
   u=current_user
   a=Application.find_by_name(params[:appli])
   if current_user.admin? || a.user_id == u.id 
   	a.destroy
   end
   redirect '/'
end

get '/:appli/session/new' do
  @a=Application.find_by_name(params["appli"])
  @or=params["origin"]
  @s=params["secret"]	
  if current_user
    if current_user.use?(@a.id)	
      redirect to Application.generate_link(params["appli"],current_user.login,@or,@s)
    else
      erb :"appli_use_account"
    end
  else
    erb :"appli_login"
  end
end

post '/:appli/session' do
  @a=Application.find_by_name(params["appli"])
  settings.logger.info("/"+params["appli"]+"/session => "+params["user"]["login"]) unless ENV['RACK_ENV']=='test'
  if session["current_user"]=User.authenticate(params["user"])
    current_user.use(@a.id)
    redirect to Application.generate_link(params["appli"],current_user.login,params["origin"],params["secret"])
  else
    @u=User.new(params["user"])
    erb :"appli_login"
  end
  
end


get '/:appli/session/continue' do
  @a=Application.find_by_name(params["appli"])
  cUser.use(@a.id)
  redirect to Application.generate_link(params["appli"],current_user,params["origin"],params["secret"])
end

post '/:appli/user' do
  @a=Application.find_by_name(params["appli"])
  @u=User.new(params["user"])
  @or=params["origin"]
  @s=params["secret"]
  if @u.save
    session["current_user"]=@u.login
    @u.use(@a.id)
    redirect to Application.generate_link(params["appli"],@u.login,@or,@s)
  else
    erb :"appli_use_account"
  end  
end

not_found do
  erb :"404"
end
