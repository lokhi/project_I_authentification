require 'active_record'

class Use < ActiveRecord::Base

  belongs_to :users
  belongs_to :applications

  validates :application_id, :presence => true
  validates :user_id, :presence => true
end
