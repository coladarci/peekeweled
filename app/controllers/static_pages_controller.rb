class StaticPagesController < ApplicationController
  def home
    if current_user
      redirect_to user_path
    else
      redirect_to signin_path
    end
  end
  def signin
  end
end
