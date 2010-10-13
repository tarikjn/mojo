class AddDuosAndStateToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :state, :string
    add_column :activities, :creator_duo_id, :integer
    add_column :activities, :invitee_duo_id, :integer
  end

  def self.down
    remove_column :activities, :invitee_duo_id
    remove_column :activities, :creator_duo_id
    remove_column :activities, :state
  end
end
