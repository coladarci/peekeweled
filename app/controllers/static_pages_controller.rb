class StaticPagesController < ApplicationController
  def home
    if current_user
      redirect_to user_path
    else
      redirect_to about_path
    end
  end
  def about

  end

end
