class StepflowController < ApplicationController
  
  # different actions:
  # go
  # next (submit)
  # previous (save, go to previous step)
  # cancel (delete session)
  
  helper_method :ongoing_view, :find_sorties
  
  def go # action for start and continue (noJS)
    if session[:stepflow] and !session[:stepflow].complete # reset if we finished before
      # continue
      @stepflow = session[:stepflow] # create new object from parameters instead to wipe out existing errors for noJS/GET reload...?
    else
      # this set up the ActiveModel object with defaults and the time from the homepage
      @stepflow = Stepflow.new(params[:stepflow].merge( (current_user)? { :host => current_user } : {} ))
      session[:stepflow] = @stepflow
    end
    
    logger.info current_user.inspect
  end
  
  def next
    @stepflow = session[:stepflow]
    @stepflow.update(params[:stepflow])
    
    m = @stepflow.move_next
    Logger.new(STDOUT).info(@stepflow.sortie.inspect)
    render_action m
    # TODO: when map error: redisplay searh q, results and even selected place?
  end
  
  def previous
    @stepflow = session[:stepflow]
    @stepflow.update(params[:stepflow] || {})
    
    render_action @stepflow.move_prev
  end
  
  def cancel
    session[:stepflow] = nil
    redirect_to path_to_url(root_path)
  end
  
  def discover_search
    # this action is for getting number of sorties matching for join
    @params = params
    render "discover"
  end
  
  def map
    flash[:list] = params[:p]
    #@step = 1
    #@previous_action = ''
  end
  
  def created
    
  end
  
  def joined
    @selected_dates = session[:selected_dates]
  end
  
private
  
  # helper method
  def find_sorties
    # look at params on @stepflow
    
    # return collection
    #Sortie.find(6,7,8)
    Sortie.find_sorties_for_user(@stepflow.host)
  end
  
  # also a helper method
  def ongoing_view(step = @stepflow.step)
    # when @stepflow is not instanciated, it's nil?
    case step
    when 0 # step 1
      'discover'
    when 1 # step 2
      @stepflow.operation
    when 2 # step 3
      (current_user)? 'review' : 'profile'
    end
  end
  
  # type is any of next, prev, error, complete
  def render_action(type)
    
    if type == 'complete'
      
      finish @stepflow.complete
      
    else # type is either next, prev or error
      
      respond_to do |format|
        format.html {
          redirect_to :action => :go
        }
        format.json {
          with_format('html') do
            render :json => {
              # tells to the JS client how to render the response (next, prev, error)
              :move => type,
              # view with no layout (complete form with nav)
              :block => render_to_string(:action => :go)
            }
          end
        }
        format.text {
          with_format('html') do
            render :json => {
              # tells to the JS client how to render the response (next, prev, error)
              :move => type,
              # view with no layout (complete form with nav)
              :block => render_to_string(:action => :go)
            }
          end
        }
      end # /respond_to
      
    end # /if type
    
  end # /render_action

  def finish(action)
    
    respond_to do |format|
      format.html {
        redirect_to :action => action
      }
      format.json {
        render :json => {
          # tells to the JS client how to render the response (redirect)
          :move => 'redirect',
          :redirect_path => url_for(:action => action)
        }
      }
      format.text {
        render :json => {
          # tells to the JS client how to render the response (redirect)
          :move => 'redirect',
          :redirect_path => url_for(:action => action)
        }
      }
    end # /respond_to
    
    
  end
  
end
