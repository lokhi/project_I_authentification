$:.unshift File.dirname(__FILE__)
require 'password'

class User < ActiveRecord::Base
#include Password
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true
  
  
  
  
end
