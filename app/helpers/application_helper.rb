module ApplicationHelper
  
  # see: http://rubypond.com/blog/useful-flash-messages-in-rails
  FLASH_NOTICE_KEYS = [:error, :notice, :success]
  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    formatted_messages = messages.map do |type|      
      content_tag :div, :class => ['flash', type.to_s] do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    formatted_messages.join.html_safe
  end
  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end
  
  # duplicated for mailer, find other way...
  # required for redirects and email urls
  # /abs -> http://myx.com/abs
  def path_to_url(path) # find something better, full url needed for redirects per HTTP
    "http://#{self.request.host}:#{self.request.port}/#{path.sub(%r[^/],'')}"
  end
  
  # refactor as a form helper, use object sub-Class
  # attribute must be a string, it is concatened with _start and _end
  def mj_timerange(name, value = nil, options = {:sorties => []})

    if value
      value = {
        :day => value.start.strftime("%F"),
        :time_start => value.start.strftime("%H:%M"),
        :time_end => value.end.strftime("%H:%M")
      }
    else
      value = {:day => nil, :time_start => nil, :time_end => nil}
    end
    
  	# start of the timerange at 6:00am
  	base_time = Date.today.to_time + 6.hours

  	ds = 19		# half-hour size in px
  	base = ds	# position of base_time

  	# elapsed = quarters in the day * qs
  	elapsed_time = Time.now - Date.today.to_time # replaced base_time by Date.today.to_time for hidden overflow
  	elapsed = (elapsed_time > 0) ? ((elapsed_time / (60 * 30)) * ds).floor : nil

  	# nice to have: show night/day even weather?, need latitude
  	set = {:ds => ds, :base => base, :elapsed => elapsed}
  	
  	# object_name is ugly, there must be a better way to do that
    render :partial => "shared/mj_timerange", :locals => {:name => name, :value => value, :options => options, :set => set}
  end
  
  def login_form
    render :partial => "user_sessions/form", :locals => { :session => UserSession.new } 
  end
  
  def format_for_errors(options, obj, attributes = nil)
    
    if (attributes and !attributes.kind_of?(Array))
      attributes = [attributes]
    end
    
    error_count = 0
    
    #Logger.new(STDOUT).info(obj.errors.inspect)
    
    if obj.errors.count > 0
      
      if !attributes
        obj.errors.to_hash.each { |v| error_count += (v.length > 0)? 1 : 0 }
      else
        attributes.each { |a| error_count += (obj.errors[a].length > 0)? 1 : 0 }
      end
      
      if error_count > 0
        (options[:class] ||= []) << 'errors-parent'
        options['data-errors'] = error_count
      end
      
    end
    options
    
  end
  
  # refactor as a form helper
  def format_errors_for(obj, symbol, options = {})
    # set options defaults
    defaults = {
      :title  => nil, # TOTO: read title from model attribute if nil
      :align  => :left,
      :abs    => false,
      :single => false
    }
    options = defaults.merge(options)
    
    # TODO: pop errors out as they are printed to know if errrors are left?
    if obj.errors[symbol].length > 0
      
      content_tag :div, :class => ( ['errors'] << ((options[:abs])? 'absolute' : nil) ) do
        content_tag :ul, :class => (options[:align] == :right)? 'right-align' : nil do
          
          obj.errors[symbol].each do |msg|
    		      concat content_tag :li, "#{options[:title]} #{msg}".html_safe
    		      break if options[:single]
    		  end
    		  
        end
      end
      
    end
  end
  
  def color_for_picture_score(score)
    # +5 -> R: 0, G: 255, B: 0
    # 0 -> R: 255, G: 255, B: 0
    # -5 -> R: 255, G: 0, B: 0
    
    red = (score > 0)? ((score/5) * 255).to_i : 255;
    green = (score < 0)? (255 + (score/5) * 255).to_i : 255;
    
    return "rgb(#{red}, #{green}, 0)"
  end
  
  # make it more OO by moving to class for object type
  def time_to_ds(str)
    m = str.match(/(\d{2}):(\d{2})/)
    hours = m[1].to_i
    minutes = m[2].to_i
    
    2*hours + minutes/30
  end
  
end
