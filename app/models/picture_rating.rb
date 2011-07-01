class PictureRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :sortie_report
  
  validates :score, :inclusion => { :in => 1..5 }
  
  after_initialize :defaults
  before_create :associate_file_name
  
private
  def associate_file_name
    # TODO: associate picture ID after reviewing workflow in details
    # for now it will just associate the picture name at the time of the report
    self.picture_file_name = self.user[:picture]
  end
  
  def defaults 
   self.score ||= 3
  end
end
