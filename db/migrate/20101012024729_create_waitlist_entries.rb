class CreateWaitlistEntries < ActiveRecord::Migration
  def self.up
    create_table :waitlist_entries do |t|
      t.references :user
      t.references :activity
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :waitlist_entries
  end
end
