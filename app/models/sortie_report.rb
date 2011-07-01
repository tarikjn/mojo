class SortieReport < ActiveRecord::Base
  belongs_to :sortie
  belongs_to :by, :class_name => "User"
  
  has_and_belongs_to_many :culprits, :class_name => "User", :join_table => "sortie_reports_culprits"
  has_many :user_ratings,    :dependent => :destroy
  has_many :picture_ratings, :dependent => :destroy
  has_one :place_review,     :dependent => :destroy
  has_one :site_review,      :dependent => :destroy
  
  accepts_nested_attributes_for :culprits, :user_ratings, :picture_ratings, :place_review, :site_review
  
  validates :result, :inclusion => { :in => %w(on-time late cancelled) }
  validates :at_location, :inclusion => { :in => [true, false] }, :unless => :cancelled?
  validates :cancellation_notice, :inclusion => { :in => %w(before after no-show) }, :if => :cancelled?
  
  attr_accessor :result
  
  before_validation :clean_associations
  
  def cancelled?
    self.result == 'cancelled'
  end
  
private

  def clean_associations
    case self.result
    when 'on-time', 'late'
      
      self.cancellation_notice = nil
      case self.at_location
      when true
      when false
        self.place_review = nil
      end
      
    when 'cancelled'
      self.at_location = nil
      self.user_ratings = []
      self.picture_ratings = []
      self.place_review = nil
    end
    
    # case statement is equivalent to elsif
    self.late_by = nil if ['on-time', 'cancelled'].include?(self.result)
    
  end
  
  # def state
  #     if self.cancellation_notice
  #       'cancelled'
  #     elsif self.late_by
  #       'late'
  #     else
  #       'on-time'
  #     end
  #   end
  #   
  #   def state=(v)
  #     case v
  #     when 'on-time'
  #       self.cancellation_notice = nil
  #       self.late_by = nil
  #     when 'late'
  #       self.cancellation_notice = nil
  #     when 'cancelled'
  #       self.late_by = nil
  #     end
  #   end
end
