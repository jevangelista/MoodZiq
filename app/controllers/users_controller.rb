class UsersController < ApplicationController
	before_action :logged_in?, only: :show

	def new
		@user = User.new
	end

	def create
	    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation, :photo)
	    @user = User.create(user_params)

	    if @user.save
		    login(@user)
		    redirect_to "/start"
		else
			redirect_to "/splash"
		end

	end

	def show
		id = params[:id]
		@user = User.find(id)
	end

end
