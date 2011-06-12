class CreatePictureRatings < ActiveRecord::Migration
  def self.up
    create_table :picture_ratings do |t|
      t.references :user
      t.string :picture_file_name
      t.references :by
      t.references :sortie
      t.integer :score

      t.timestamps
    end
  end

  def self.down
    drop_table :picture_ratings
  end
end
