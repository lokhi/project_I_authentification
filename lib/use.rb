require 'active_record'

class Use < ActiveRecord::Base

  belongs_to :user
  belongs_to :application

  validates :application_id, :presence => true
  validates :user_id, :presence => true
end
