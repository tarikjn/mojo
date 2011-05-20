# http://blog.jepamedia.org/2008/12/20/rails-extend-formhelper-for-custom-form-elements/
# TODO put into app/helpers?
module ActionView
  module Helpers
  
    module FormHelper
  
      def height_field(object, object_name, method, options = {}, html_options = {})
        
        Logger.new(STDOUT).info(["METHOD: ", method].inspect)
        html = ""
        html << '<div class="mj-height-input">'
        html << label_tag(nil, 
                number_field_tag(object_name + "[#{method}][feet]",
                  (object.send(method).get_ft unless object.send(method).nil?),
                  :class => "ft-text-input", :size => 1) + ' <span class="unit">ft</span> '.html_safe)
        html << label_tag(nil, 
                number_field_tag(object_name + "[#{method}][inches]",
                  (object.send(method).get_in unless object.send(method).nil?),
                  :class => "in-text-input", :size => 2) + ' <span class="unit">in</span>'.html_safe)
        html << '</div>'
        html.html_safe
             
      end

    end
 
    class FormBuilder
  
      def height_field(method, options = {}, html_options = {})
        @template.height_field(@object, @object_name, method, objectify_options(options), @default_options.merge(html_options))
      end

    end

  end
end
