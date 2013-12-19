class UserController < ApplicationController
  
  before_action :signed_in_user
  before_action :set_user, only: [:show]
  
  def show
    @leaderboard = Game.all.group('user_id, games.id').order("score desc").limit(10)
  end
  
  private
  
    def set_user
      @user = current_user
    end
end

