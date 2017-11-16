class MainController < ApplicationController
  def main
    sub_route = params[:role]

    @network_name = ENV['NETWORK_NAME'] || ''
    if current_user
      @login_type = current_user.counselor? ? 'admin' : 'user'
      @login_id = current_user.email
    else
      @login_type = 'none'
    end
    
    @screen_role = 'admin' if sub_route == 'admin'
  end
end
