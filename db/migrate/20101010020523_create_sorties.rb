class CreateSorties < ActiveRecord::Migration
  def self.up
    create_table :sorties do |t|
      t.integer :size, :default => 2, :null => false
      t.string :state, :null => false
      t.references :host, :null => false
      t.references :guest
      t.string :category
      t.timestamp :time
      t.references :place
      t.string :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :sorties
  end
end
