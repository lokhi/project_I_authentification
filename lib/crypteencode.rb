module CrypteEncode
  require 'openssl'
  require 'base64'

  def cypher(key,login)
    pubkey=OpenSSL::PKey::RSA.new(key)
    clogin=pubkey.public_encrypt(login)
    elogin=Base64.urlsafe_encode64(clogin)
  end
  
  
  def decypher(key,elogin)
    clogin=Base64.urlsafe_decode64(elogin)
    privkey=OpenSSL::PKey::RSA.new(key)
    login=privkey.private_decrypt(clogin)
  end
end
