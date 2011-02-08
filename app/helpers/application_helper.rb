module ApplicationHelper
  
  # /abs -> http://myx.com/abs
  def path_to_url(path) # find something better
    "http://#{self.request.host}:#{self.request.port}/#{path.sub(%r[^/],'')}"
  end
  
  def mj_timerange(show_activities = false)
    # TODO: move to helper
    render :partial => "shared/mj_timeline", :locals => {:show_activities => show_activities}
  end
  
  def login_form
    render :partial => "user_sessions/form", :locals => { :session => UserSession.new } 
  end
  
  def format_errors_for(obj, symbol, title)
    o = ''
    if obj.errors[symbol].length > 0
      o << '<ul class="errors">'
      obj.errors[symbol].each do |msg|
		      o << "<li>#{title} #{msg}</li>"
		  end
      o << '</ul>'
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
  
end
