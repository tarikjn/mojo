class AddStateDefaultToActivities < ActiveRecord::Migration
  def self.up
    change_column :activities, :state, :string, :default => 'open'
  end

  def self.down
  end
end
