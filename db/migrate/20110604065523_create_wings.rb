class CreateWings < ActiveRecord::Migration
  def self.up
    create_table :wings do |t|
      t.references :lead
      t.references :mate

      t.timestamps
    end
  end

  def self.down
    drop_table :wings
  end
end
