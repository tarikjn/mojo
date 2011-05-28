class AddPictureToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :picture, :string
    remove_column :users, :picture_url
  end

  def self.down
    remove_column :users, :picture
    add_column :users, :picture_url, :string
  end
end
