class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :kind
      t.float :lat, :null => false
      t.float :lng, :null => false
      t.string :provider
      t.string :provider_id
      t.string :name
      t.string :address
      t.string :city
      t.string :state_code
      t.string :postal_code
      t.string :country_code
      t.string :cross_streets
      t.string :neighborhoods

      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
