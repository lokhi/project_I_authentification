require 'digest/sha1'
require 'active_record'

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
  
  
  
end
