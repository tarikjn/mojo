class AddStateDefaultToWaitlistEntries < ActiveRecord::Migration
  def self.up
    change_column :waitlist_entries, :state, :string, :default => 'waiting'
  end

  def self.down
  end
end
