class FixSortieReportNestedAssociations < ActiveRecord::Migration
  TABLES = [:user_ratings, :picture_ratings, :place_reviews, :site_reviews]
  
  def self.up
    
    TABLES.each do |t|
      add_column t, :sortie_report_id, :integer
      remove_column t, :by_id
      remove_column t, :sortie_id
    end
    
  end

  def self.down
    
    TABLES.each do |t|
      add_column t, :sortie_id, :integer
      add_column t, :by_id, :integer
      remove_column t, :sortie_report_id
    end
    
  end
end
