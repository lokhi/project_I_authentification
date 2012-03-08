require 'digest/sha1'

class User < ActiveRecord::Base
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true
  
  def password=(clear_pass)
    write_attribute(:password, Digest::SHA1.hexdigest(clear_pass))
  end
end
