require 'digest/sha1'
require 'active_record'
require 'openssl'
require_relative 'application'

class User < ActiveRecord::Base

  has_many :applications
  has_many :uses
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true
  
  
  def password=(clear_pass)
    write_attribute(:password, Digest::SHA1.hexdigest(clear_pass).inspect[1,40])
  end
  
  
  
  def self.authenticate(hash)
    user=find_by_login(hash["login"])
    if user && user.password == Digest::SHA1.hexdigest(hash["password"])
      user
    else
      nil
    end
  end
  
  
  def self.appli_authenticate(hash,appli)
    if User.authenticate(hash)
    	key=Application.find_by_name(appli).key
    	pubkey=OpenSSL::PKey::RSA.new(key)
    	clogin=pubkey.public_encrypt(hash["login"])
    	blogin=Base64.urlsafe_encode64(clogin)
    else
      nil
    end
 end
end
