class CreateEntryActions < ActiveRecord::Migration
  def self.up
    create_table :entry_actions do |t|
      t.references :entry, :null => false
      t.references :by, :null => false
      t.string :action, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :entry_actions
  end
end
