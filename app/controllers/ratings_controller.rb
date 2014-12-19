class RatingsController < ApplicationController
	before_filter :load_user
	load_and_authorize_resource

	def index
		@user = User.find(params[:user_id])
    	@ratings = @user.ratings.order(created_at: :desc).page(params[:page])
	end

	def show
		@rating = Rating.find(params[:id])
	end

	def create
		@rating = @user.ratings.build(rating_params)

		respond_to do |format|
			if @rating.save
				format.html {redirect_to users_path(current_user), notice: "Rating successfully created"}
				format.js {}
			else
				format.html {render 'movie_interests/new'}
				format.js {}
			end
		end
	end

	def destroy
		@rating = Rating.find(params[:id])
		@rating.destroy
		redirect_to user_path(current_user)
	end

	private
	def rating_params
		params.require(:rating).permit(:user_id, :user_score, :watched, :review, :rt_id, :actors, :directors, :genres)
	end

	def load_user
		@user = User.find(params[:user_id])
	end
end
