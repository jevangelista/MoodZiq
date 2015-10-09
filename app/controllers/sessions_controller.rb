class SessionsController < ApplicationController
  def new
    @user = User.new
    render :new
	end

  def create
  	user_params = params.require(:user).permit( :email, :password)
  	@user = User.confirm(user_params)
		if @user
  			login(@user)
  			redirect_to "/start"
		else

  			redirect_to "/splash", flash: { error: "Failed To Authenticate. Please try again." }
		end
	end

	def destroy
		@current_user = session[:user_id] = nil
		redirect_to "/splash"
	end
end
