class CreateSortieUpdates < ActiveRecord::Migration
  def self.up
    create_table :sortie_updates do |t|
      t.references :sortie, :null => false
      t.references :by, :null => false
      t.string :kind, :null => false
      t.integer :late_by

      t.timestamps
    end
  end

  def self.down
    drop_table :sortie_updates
  end
end
