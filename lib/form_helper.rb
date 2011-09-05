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
      
      # def gender_field(object, object_name, method, options = {}, html_options = {})
      #         
      #         content_tag :div, :class => ['mj-merged-choices', 'hybrid-input'] do
      #           person_choice(object, object_name, method, 'male')
      #           +
      #           person_choice(object, object_name, method, 'female')
      #         end
      #       
      #       end
      
      # refactor, this is probably not where its supposed to be
      def person_choice(object, object_name, method, value, options = {}, html_options = {})
        
        images = {
          'male'   => 'guy',
          'both'   => 'person',
          'female' => 'gal'
        }
        titles = {
          'male'   => 'Guy',
          'both'   => 'Both',
          'female' => 'Girl'
        }
        
        defaults = {
          :title => titles[value]
        }
        options = defaults.merge(options)
        
        label_tag do
          radio_button_tag("#{object_name}[#{method}]", value, object.send(method) == value) +
          content_tag(:div, :class => 'person') do
            content_tag(:div, image_tag("/assets/icons/#{images[value]}.png"), :class => 'img') +
            content_tag(:div, options[:title], :class => 'title')
          end
        end
        
      end

    end
 
    class FormBuilder
  
      def height_field(method, options = {}, html_options = {})
        @template.height_field(@object, @object_name, method, objectify_options(options), @default_options.merge(html_options))
      end
      
      def person_choice(method, value, options = {}, html_options = {})
        @template.person_choice(@object, @object_name, method, value, objectify_options(options), @default_options.merge(html_options))
      end

    end

  end
end
