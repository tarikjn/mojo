class CreatePlaceYelps < ActiveRecord::Migration
  def self.up
    create_table :place_yelps do |t|
      t.references :place
      t.string :url
      t.integer :review_count
      t.string :rating_img_url_small

      t.timestamps
    end
  end

  def self.down
    drop_table :place_yelps
  end
end
