class CreatePlaceReviews < ActiveRecord::Migration
  def self.up
    create_table :place_reviews do |t|
      t.references :place
      t.references :by
      t.references :sortie
      t.integer :score
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :place_reviews
  end
end
