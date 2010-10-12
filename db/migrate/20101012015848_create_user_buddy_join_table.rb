class CreateUserBuddyJoinTable < ActiveRecord::Migration
  def self.up
    create_table :users_buddies, :id => false do |t|
      t.integer :user_id
      t.integer :buddy_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users_buddies
  end
end
