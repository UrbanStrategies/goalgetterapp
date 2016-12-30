module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      p = params[:user]
      if !(p.select { |k, v| !v.nil? && v.strip != '' }.keys.sort == reqd_keys.sort &&
           p[:password_confirmation] == p[:password])
        flash[:error] = "Supply both email and password, and ensure passwords match."
        redirect_to new_user_registration_path
      else
        u = User.new email: params[:user][:email], password: params[:user][:password]
        u.save
        u.build_profile
        u.profile.save
        redirect_to root_path
      end
    end

    protected
    def invalid_login_attempt
      set_flash_message(:alert, :invalid)
      render json: flash[:alert], status: 401
    end

    private
    def reqd_keys
      ["email", "first_name", "last_name", "password", "password_confirmation"]
    end
  end
end