class AddPlaceToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :place_id, :integer
  end

  def self.down
    remove_column :activities, :place_id
  end
end
