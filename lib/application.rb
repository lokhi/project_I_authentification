require 'active_record'
require 'openssl'
require_relative 'crypteencode'
require_relative 'use'

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
    app=Application.find_by_name(appli)
    blogin=app.cypher(app.key,login)
    app.adresse+orig+"?login="+blogin+"&secret="+secret
  end
  
  def self.list_app_used_by(id)
    use=Use.where(:user_id => id)
    res=[]
    if use
      use.each do |u|
        res.push(Application.find_by_id(u.application_id))
      end
    end
    res
  end
  
end
