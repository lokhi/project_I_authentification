require 'sinatra'
require 'openssl'
require 'base64'

get '/test' do
pubkey=OpenSSL::PKey::RSA.new(File.read("Poc/public.pem"))
clogin=pubkey.public_encrypt("toto")
blogin=Base64.urlsafe_encode64(clogin)
redirect "/testR?login=#{blogin}"
end

get '/testR' do
privkey=OpenSSL::PKey::RSA.new(File.read("Poc/private.pem"))
clogin=Base64.urlsafe_decode64(params["login"])
login=privkey.private_decrypt(clogin)
login
end
