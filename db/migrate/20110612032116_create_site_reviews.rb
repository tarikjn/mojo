class CreateSiteReviews < ActiveRecord::Migration
  def self.up
    create_table :site_reviews do |t|
      t.references :by
      t.references :sortie
      t.integer :score
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :site_reviews
  end
end
