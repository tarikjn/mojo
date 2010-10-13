class CreateDuos < ActiveRecord::Migration
  def self.up
    create_table :duos do |t|
      t.integer :host_id
      t.integer :participant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :duos
  end
end
