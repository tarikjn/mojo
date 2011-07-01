class UserRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :sortie_report
  
  validates :score, :inclusion => { :in => 1..5 }
end
