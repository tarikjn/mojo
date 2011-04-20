module ApplicationHelper
  
  # attribute must be a string, it is concatened with _start and _end
  def mj_timerange(name, value = {:day => nil, :time_start => nil, :time_end => nil}, options = {:show_activities => false})

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
  
  def format_errors_for(obj, symbol, options = {:title => nil, :align => :left})
    o = ''
    if obj.errors[symbol].length > 0
      o << '<div class="errors"><ul' + ((options[:align] == :right)? ' class="right-align"' : '') + '>'
      obj.errors[symbol].each do |msg|
		      o << "<li>#{options[:title]} #{msg}</li>"
		  end
      o << '</ul></div>'
    end
    raw o
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
