require 'active_record'
require 'securerandom'

class Application < ActiveRecord::Base

  belongs_to :user

  validates :name, :presence => true
  validates :adresse, :presence => true
  validates :name, :uniqueness => true
  validates :user_id, :presence => true
  
  
  
  before_save :generate_secret

  def generate_secret
     self.secret=SecureRandom.uuid
  end
  
  
  
end
