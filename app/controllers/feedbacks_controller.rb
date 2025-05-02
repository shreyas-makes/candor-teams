class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_team
  
  def matrix
    users = current_user.team.users
    render json: Feedback.matrix_for(users)
  end

  def heat_map
    @users = current_user.team.users
  end

  private

  def require_team
    unless current_user.team
      redirect_to subscribe_index_path, alert: "You need to create or join a team first."
    end
  end
end 