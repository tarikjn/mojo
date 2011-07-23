class CreateFollows < ActiveRecord::Migration
  def self.up
    create_table :follows do |t|
      t.references :follower
      t.references :followed

      t.timestamps
    end
    add_index :follows, :follower_id
    add_index :follows, :followed_id
    add_index :follows, [:follower_id, :followed_id], :unique => true
  end

  def self.down
    drop_table :follows
  end
end
