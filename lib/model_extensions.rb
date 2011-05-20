# see: http://stackoverflow.com/questions/2328984/rails-extending-activerecordbase/2330533#2330533
module ActiveModelExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end

  # add your instance methods here
  def clear_errors
    @errors = ActiveModel::Errors.new(self)
  end

  module ClassMethods
    # add your static(class) methods here
  end
end
# include the extension 
#ActiveRecord::Base.send(:include, MyActiveRecordExtensions)
