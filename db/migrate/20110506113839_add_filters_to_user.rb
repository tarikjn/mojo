class AddFiltersToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :filter_age, :boolean, :null => false, :default => false
    add_column :users, :filter_height, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :filter_height
    remove_column :users, :filter_age
  end
end
