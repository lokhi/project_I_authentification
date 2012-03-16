require 'active_record'
require 'openssl'

class Application < ActiveRecord::Base

  belongs_to :user
  has_many :uses

  validates :name, :presence => true
  validates :adresse, :presence => true
  validates :name, :uniqueness => true
  validates :key, :presence => true
  validates :user_id, :presence => true  
  
  
  def self.appli_crypte_encode(appli,login)
    key=Application.find_by_name(appli).key
    pubkey=OpenSSL::PKey::RSA.new(key)
    clogin=pubkey.public_encrypt(login)
    blogin=Base64.urlsafe_encode64(clogin)
  end

  
end
