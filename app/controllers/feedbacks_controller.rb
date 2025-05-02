class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  
  def matrix
    users = current_user.team.users
    render json: Feedback.matrix_for(users)
  end

  def heat_map
    @users = current_user.team.users
  end
end 