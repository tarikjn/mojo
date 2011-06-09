class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.references :sender
      t.string :recipient_email
      t.string :token, :null => false
      t.datetime :sent_at

      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
