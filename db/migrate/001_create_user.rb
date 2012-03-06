class CreateUser < ActiveRecord::Migration
  def up
    create_table :user do |t|
    end
  end

  def down
    destroy_table :user
  end
end
