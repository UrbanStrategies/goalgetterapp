class ProfilesController < ApplicationController
  before_action :authorize_actions!
  before_action :require_xhr, only: [:show, :update] # this requires the format to end in .json

  include DataFetchers
  include ProfileUpdaters

  def public
    if current_user
      redirect_to root_path(screen: 'public-portfolio', 'public-portfolio-name' => params[:identifier])
    else
      session[:return_to] = public_profile_path(identifier: params[:identifier])
      u = User.find_by_slug params[:identifier]
      if u
        flash[:notice] = t('messages.login_to_view', fullname: u.full_name)
      end
      redirect_to new_user_session_path
    end
  end
  
  def index
  end

  def add_photo
    updated = false
    if current_user
      p = current_user.profile
      p.profile_pic = params[:file]
      if p.save
        updated = true
      end
    end

    if !updated
      head :ok
    else
      render json: ({redirect: '3'}), status: :ok
    end
  end
  
  def update
    # This call has to be via XMLHTTPRequest.
    # The payload comes in as a specific ordering of data that is determined by the
    # [:payload][:code] parameter.

    resp = {}
    u = current_user || (current_admin and User.find_by_id(params[:user]))
    if u
      case params.dig(:payload, :code)
      when 'toggle-publish'
        p = u.profile
        p.published = !(p.published)
        p.save
        resp = {profile_published: p.published}
      when 'set-to-read'
        if (type = params.dig(:payload, :data, :type)).present? # Expect this.
          AccountInboxMessage.set_to_read type, u
          resp = {type: type}
        end
      when /friend$/
      # add or remove friends
        resp = process_friendship u, params
      end
      status = 200
    else
      status = 422
    end
    render json: ({data: resp}), status: status
  end

  def show
    if Rails.env.test? and ENV['IS_SLOW'] == '1'
      sleep 2
    end

    screen_name = params[:screen_name]
    d = ({data: {}})

    public_user = nil
    u = (screen_name == 'public-portfolio' && (public_user = User.publicly_found(params[:public_name]))) ? 
          public_user : current_user

    if u
      is_friend = public_user && current_user.friends.include?(public_user)
      d[:data].merge!(
        case screen_name
        when '2'
          counselor_list u
        when '3'
          portfolio_data u, tab: 'public'
        when '4'
          contacts_data u
          
        when 'portfolio-friends'
          h = portfolio_data(u, tab: 'friends').tap do |hash|
            hash[:friend_entries].each do |entry|
              if entry.keys.include? :public_link
                entry[:public_link] = public_profile_url(identifier: entry[:public_link])
              end
            end
          end
          h
        when 'portfolio-likes'
          portfolio_data u, tab: 'likes'
        when 'chat'
          user_chat_data u
        when 'public-portfolio'
          portfolio_data u, tab: 'public', is_friend: is_friend
        else
          {}
        end
      )
    
      # global data for logged-in case: inbox
      d[:data][:inbox] = u.inbox(unread: true)[:unread_inbox].group_by do |hash|
        hash[:alert_type]
      end
    end
    
    render json: d
  end

  private
  def authorize_actions!
    _abort = false
    case params[:action]
    when :index
      _abort = current_admin.nil?
    when :update
      _abort = current_user.nil? && current_admin.nil?
    end

    if _abort
      throw :abort
    end
  end
end
