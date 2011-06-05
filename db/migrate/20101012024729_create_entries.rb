class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.references :party
      t.references :sortie
      t.string :state, :default => 'waiting', :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
