class AddCompletenessToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :completeness, :string, { :default => 'complete', :null => false }
  end

  def self.down
    remove_column :users, :completeness
  end
end
