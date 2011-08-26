class FriendshipsController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def index
    # move to a sortie controller method?
    @received_sortie_requests = current_user.mate_host_sorties.unconfirmed
    @sent_sortie_requests = current_user.lead_host_sorties.unconfirmed
  end

  def new
    # this one is called through AJAX (link_to_remote style)
    
    @friendship = Friendship.new
    #@friendship.user = current_user
    @friendship.friend = User.new # if not found by email
    @friendship.friend.state = 'invitation'
    @friendship
    
    render :layout => !request.xhr?
  end

  def create
    @friendship = Friendship.new(params[:friendship])
    @friendship.user = current_user
    
    # can the friend be found by email? (registered or simply already invited)
    if friend_result = User.find_by_email(@friendship.friend.email)
      @friendship.friend = friend_result
    end
    
    if @friendship.save
      # TODO: show invitation limit errors (error.base)
      
      if @friendship.friend.registered?
        # email friend added notice
        Notifier.friend_request(@friendship).deliver
      else
        # send friend's invitation, invitation was automatically created by model
        Notifier.friend_invite(@friendship, @friendship.invitation).deliver
      end
      
      # for friendlist redisplay
      @preselect_friend = @friendship.friend.id
      
      flash[:notice] = "You successfully added your friend!"
      with_format('html') do
        render :json => {
          :action => 'redirect', # any of redirect, block
          :redirect_path => url_for(:action => :index),
          # return new friendlist for sorties
          # don't generate code otherwise: use Backbone.js?
          :new_friendlist => render_to_string(:partial => 'friendlist.select', :layout => false)
        }
      end
      
    else
      Logger.new(STDOUT).info(@friendship.errors.inspect)
      
      with_format('html') do
        render :json => {
          :action => 'block', # any of redirect, block
          :block => render_to_string(:partial => 'form', :layout => false)
        }
      end
      
    end
  end
  
  def withdraw
    user = current_user
    friend = User.find(params[:user_id])
    unless friend.nil?
      if Friendship.withdraw(user, friend)
        flash[:notice] = "Friend request with #{friend.name} withdrawn"
      else
        flash[:error] = "Friend request with this user cannot be withdrawn"
      end
    end
    redirect_to friendships_url
  end

  def approve
    user = current_user
    friend = User.find(params[:user_id])
    unless friend.nil?
      if Friendship.approve(user, friend)
        flash[:notice] = "You and #{friend.name} are now wingmates!"
        Notifier.friend_approved(friend, user).deliver
      else
        flash[:error] = "Friend request with this user cannot be approved"
      end
    end
    redirect_to friendships_url
  end

  def ignore
    user = current_user
    friend = User.find(params[:user_id])
    unless friend.nil?
      if Friendship.ignore(user, friend)
        flash[:notice] = "You ignored #{friend.name}'s friend request"
      else
        flash[:error] = "Friend request with this user cannot be ignored"
      end
    end
    redirect_to friendships_url
  end

  def delete
    user = current_user
    friend = User.find(params[:user_id])
    unless friend.nil?
      if Friendship.delete(user, friend)
        flash[:notice] = "You are no longer wingmate with #{friend.name}"
      else
        flash[:error] = "User cannot be removed from your friends"
      end
    end
    redirect_to friendships_url
  end

end
