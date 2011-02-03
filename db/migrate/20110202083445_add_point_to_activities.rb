class AddPointToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :lat, :float
    add_column :activities, :lng, :float
  end

  def self.down
    remove_column :activities, :lat
    remove_column :activities, :lng
  end
end
