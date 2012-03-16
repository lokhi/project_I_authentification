require 'active_record'
require 'openssl'
require_relative 'crypteencode'

class Application < ActiveRecord::Base
include CrypteEncode
  belongs_to :user
  has_many :uses

  validates :name, :presence => true
  validates :adresse, :presence => true
  validates :name, :uniqueness => true
  validates :key, :presence => true
  validates :user_id, :presence => true  
  

  
  def self.generate_link(appli,login,orig,secret)
    #blogin=Application.appli_crypte_encode(appli,login)
    app=Application.find_by_name(appli)
    blogin=app.cypher(app.key,login)
    app.adresse+orig+"?login="+blogin+"&secret="+secret
  end
  
end
