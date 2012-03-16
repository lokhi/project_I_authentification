module CrypteEncode
  require 'openssl'
  require 'base64'

  def cypher(key,login)
    pubkey=OpenSSL::PKey::RSA.new(key)
    clogin=pubkey.public_encrypt(login)
    blogin=Base64.urlsafe_encode64(clogin)
  end
end
