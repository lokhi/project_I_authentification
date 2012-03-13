class ApplicationAddNameAdresseKeyUser < ActiveRecord::Migration
  def up
    add_column :applications, :name, :string
    add_column :applications, :adresse, :string
    add_column :applications, :key, :string
    add_column :applications, :user_id, :integer
  end

  def down
    remove_column :applications, :name
    remove_column :applications, :adresse
    remove_column :applications, :key
    remove_column :applications, :user_id
  end
end
