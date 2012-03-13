require 'sinatra'
require 'securerandom'

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

def generate_secret
  SecureRandom.urlsafe_base64
end

get '/' do
 "Application"
end



get '/protected' do
  if params["login"].nil? #&& params["secret"].nil?
    secret =generate_secret
    session[secret]=Time.now.to_i
    redirect "http://sauth/appli1/session/new?origin=/protected&secret=#{secret}"
  else
    #if session[params["secret"]] && (Time.now.to_i - session[params["secret"]] < 60)
     clogin=Base64.urlsafe_decode64(params["login"])
     privkey=File.read('private.pem')
     login=privkey.private_decrypt(privkey)

  end
end
