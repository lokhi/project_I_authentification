require 'digest/sha1'
require 'active_record'
require_relative 'use'
require_relative 'application'
class User < ActiveRecord::Base

  has_many :applications, :dependent => :delete_all
  has_many :uses, :dependent => :delete_all
  
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true
  
  
  def password=(clear_pass)
    if !clear_pass.empty?
      write_attribute(:password, Digest::SHA1.hexdigest(clear_pass).inspect[1,40])
    else
      nil?
    end
  end
  
  
  
  def self.authenticate(hash)
    user=find_by_login(hash["login"])
    if user && user.password == Digest::SHA1.hexdigest(hash["password"])
      user
    else
      nil
    end
  end
  
  def use?(id)
    Use.exists?(:user_id=>self.id,:application_id=>id)
  end
  
  def use(id)
    if !self.use?(id)
      us=Use.new
      us.user_id=self.id
      us.application_id=id
      us.save
    end
  end
  
end
