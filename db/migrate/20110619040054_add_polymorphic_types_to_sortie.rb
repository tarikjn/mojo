class AddPolymorphicTypesToSortie < ActiveRecord::Migration
  def self.up
    add_column :sorties, :host_type, :string
    add_column :sorties, :guest_type, :string
  end

  def self.down
    remove_column :sorties, :guest_type
    remove_column :sorties, :host_type
  end
end
