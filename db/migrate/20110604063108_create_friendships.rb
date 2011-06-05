class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.references :user
      t.references :friend
      t.boolean :approved

      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
