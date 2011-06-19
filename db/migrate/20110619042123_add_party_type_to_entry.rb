class AddPartyTypeToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :party_type, :string
  end

  def self.down
    remove_column :entries, :party_type
  end
end
