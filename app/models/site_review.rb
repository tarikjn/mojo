class SiteReview < ActiveRecord::Base
  belongs_to :sortie_report
  
  validates :score, :inclusion => { :in => 1..5 }, :allow_nil => true
end
