class SortieReport < ActiveRecord::Base
  belongs_to :sortie
  belongs_to :by, :class_name => "User"
  has_and_belongs_to_many :culprits, :class_name => "User", :join_table => "sortie_reports_culprits"
  
  validates :cancellation_notice, :inclusion => { :in => %w(before after no-show) }, :allow_nil => true
end
