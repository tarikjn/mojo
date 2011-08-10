class AddPolymorphicSourceInInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :source_type, :string, :default => 'User'
    rename_column :invitations, :sender_id, :source_id
  end

  def self.down
    rename_column :invitations, :source_id, :sender_id # should also extract User sender_id?
    remove_column :invitations, :source_type
  end
end
