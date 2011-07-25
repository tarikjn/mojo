class AddFoodiaToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :show_foodia, :boolean, :default => 1
  end

  def self.down
    remove_column :users, :show_foodia
  end
end
