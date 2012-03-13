class CreateApplications < ActiveRecord::Migration
  def up
    create_table :applications do |t|
    end
  end

  def down
    destroy_table :applications
  end
end
