class CreateUserRatings < ActiveRecord::Migration
  def self.up
    create_table :user_ratings do |t|
      t.references :user
      t.references :by
      t.references :sortie
      t.integer :score

      t.timestamps
    end
  end

  def self.down
    drop_table :user_ratings
  end
end
