class CreateSortieReports < ActiveRecord::Migration
  def self.up
    create_table :sortie_reports do |t|
      t.references :sortie, :null => false
      t.references :by, :null => false
      t.boolean :at_location
      t.string :cancellation_notice
      t.integer :late_by

      t.timestamps
    end
  end

  def self.down
    drop_table :sortie_reports
  end
end
