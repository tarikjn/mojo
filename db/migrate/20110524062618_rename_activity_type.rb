class RenameActivityType < ActiveRecord::Migration
  def self.up
    rename_column :activities, :activity_type, :category
  end

  def self.down
    rename_column :activities, :category, :activity_type
  end
end
