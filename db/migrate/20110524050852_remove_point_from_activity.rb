class RemovePointFromActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :lat
    remove_column :activities, :lng
  end

  def self.down
    add_column :activities, :lng, :float
    add_column :activities, :lat, :float
  end
end
