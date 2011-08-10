class AddStateInFriendships < ActiveRecord::Migration
  def self.up
    add_column :friendships, :state, :string, :default => 'pending'
    remove_column :friendships, :approved
  end

  def self.down
    remove_column :friendships, :state
    add_column :friendships, :approved, :boolean
  end
end
