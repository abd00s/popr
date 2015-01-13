class UsersController < ApplicationController
  load_and_authorize_resource
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to root_path, notice: "Success! Welcome to Popr!"
    else
      flash.now[:alert] = "An error occurred!"
      render 'events/welcome'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_path, notice: "User deleted :("
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to user_path(@user), notice: "Changes successful."
    else
      flash.now[:alert] = "An error occurred!"
      render 'edit'
    end
  end

  def index
    @users = if params[:user_search]
      User.where("LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) LIKE LOWER(?)", "%#{params[:user_search]}%", "%#{params[:user_search]}%").select{|u| !u.is_friend?(current_user)}.sort{|x,y| x.first_name <=> y.first_name}
    else
      User.select{|u| !u.is_friend?(current_user) && u.id != current_user.id}.sort{|x,y| x.first_name <=> y.first_name}
    end
  end

  def show
    sleep(0.2)
    @user = User.find(params[:id])
    @ratings = @user.ratings.order(created_at: :desc).page(params[:ratings_page]).per(3)
     
    if params[:friend_search]
      @friends = User.where("LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) LIKE LOWER(?)", "%#{params[:friend_search]}%", "%#{params[:friend_search]}%").select{|u| u.is_friend?(@user)}.sort{|x,y| x.first_name <=> y.first_name}
      @friends = Kaminari.paginate_array(@friends).page(params[:friends_page]).per(6)
    else
      @friends = @user.friendships.sort{|x,y| x.friend.first_name <=> y.friend.first_name}
      @friends = Kaminari.paginate_array(@friends).page(params[:friends_page]).per(6)
    end

    @user_id = @user.id
    gon.user_id = @user.id


    if @user.ratings.any?
      print totalScore = (@user.ratings.all.inject(0){|sum, rating| sum + rating.user_score}).to_f
      print maxScore = ((@user.ratings.all.count) * 5).to_f
      print averageScore = ((totalScore / maxScore).to_f * 100.0).round(1)
      print gon.average = ["Average Movie Rating", averageScore]

      # Favourite Genres
      def pieData(dataList)
        dataHash = dataList.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
        dataArray = dataHash.map{|key, value| [key, value]}
        sortedArray = dataArray.sort!{|x,y| y[1] <=> x[1]}
        if sortedArray.length < 5
          return sortedArray[0..sortedArray.length]
        else
          return sortedArray[0..4] << ["Other", sortedArray[5..-1].inject(0){|sum, x| sum + x[1]}]
        end
      end

      genreList = @user.ratings.all.map{|rating| [] << rating.genres.split(", ").flatten}.flatten
      gon.genres = pieData(genreList);

      actorsList = @user.ratings.all.map{|rating| [] << rating.actors.split(", ").flatten}.flatten
      gon.actors = pieData(actorsList);

      directorsList = @user.ratings.all.map{|rating| [] << rating.directors.split(", ").flatten}.flatten
      gon.directors = pieData(directorsList);
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :avatar, :bio, :hometown)
  end
end
