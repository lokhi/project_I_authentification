class CreateUses < ActiveRecord::Migration
  def up
    create_table :uses do |t|
      t.integer :application_id
      t.integer :user_id
    end
  end

  def down
    destroy_table :uses
  end
end
