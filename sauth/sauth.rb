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

before '/admin*' do
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
  settings.logger.info("/session => "+params["user"]["login"]) unless ENV['RACK_ENV']=='test'
  if User.authenticate(params["user"])
    login=params["user"]["login"]
    session["current_user"]=login
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
  @a=Application.find_by_name(params["appli"])
  @or=params["origin"]
  @s=params["secret"]	
  if current_user
    if cUser.use?(@a.id)	
      redirect to Application.generate_link(params["appli"],current_user,@or,@s)
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
  if @u=User.authenticate(params["user"])
    session["current_user"]=@u.login
    @u.use(@a.id)
    redirect to Application.generate_link(params["appli"],@u.login,params["origin"],params["secret"])
  else
    
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


get '/admin' do
  @u=User.all
  @a=Application.all
  erb :"admin"
end


get '/admin/user/:user/destroy' do
  u = User.find_by_login(params[:user])
  u.destroy
  redirect '/admin'
end

get '/admin/appli/:appli/destroy' do
  a = Application.find_by_name(params[:appli])
  a.destroy
  redirect '/admin'
end

not_found do
  erb :"404"
end
