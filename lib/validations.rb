# TODO: rename method to avoid confusion with deprecated method of ActiveRecord
# config/initializers/validation_fixes.rb
module ValidatesAssociatedAttributes
  module ActiveModel::Validations::ClassMethods
    def validates_active_associated(*associations)
      class_eval do
        validates_each(associations) do |record, associate_name, value|
          (value.respond_to?(:each) ? value : [value]).each do |rec|
            # added active validations hack
            if rec && record.active_validations.include?(associate_name) && !rec.valid?
              #rec.errors.each do |key, value|
                #record.errors.add(key, value)
              #end
              record.errors.add(associate_name)
            end
          end
        end
      end
    end
  end
end

# http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp/
require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain and that value is an email address
      r = m.domain && m.address == value
      t = m.__send__(:tree)
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      r &&= (t.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e   
      r = false
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless r
  end
end
