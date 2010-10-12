class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :cellphone
      t.string :picture_url
      t.string :sex
      t.string :sex_preference
      t.date :dob
      t.integer :min_age
      t.integer :max_age
      t.integer :height
      t.integer :min_height
      t.integer :max_height

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
