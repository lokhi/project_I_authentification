require 'digest/sha1'

class User < ActiveRecord::Base
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true
  
  def password=(clear_pass)
    write_attribute(:password,User.encrypt(clear_pass))
  end
  
  def self.encrypt(clear_text)
    Digest::SHA1.hexdigest(clear_text)
  end
  
  
end
