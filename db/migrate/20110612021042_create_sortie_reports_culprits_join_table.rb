class CreateSortieReportsCulpritsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :sortie_reports_culprits, :id => false do |t|
      t.references :sortie_report
      t.references :user
    end
  end

  def self.down
    drop_table :sortie_reports_culprits
  end
end
