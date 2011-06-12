class SortieUpdate < ActiveRecord::Base
  belongs_to :sortie
  belongs_to :by, :class_name => "User"
  
  validates :kind, :inclusion => { :in => %w(cancel late) }
end
