class InvitesController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  skip_before_action :authenticate_user!, only: [:claim]

  def create
    # Check if current user has a team
    unless current_user.team.present?
      redirect_to root_path, alert: "You need to be part of a team to send invites"
      return
    end
    
    @invite = Invite.new(invite_params)
    @invite.team = current_user.team

    if @invite.save
      InviteMailer.new_invite(@invite).deliver_later
      redirect_to dashboard_index_path, notice: "Invitation sent to #{@invite.email}"
    else
      redirect_to dashboard_index_path, alert: @invite.errors.full_messages.join(", ")
    end
  end

  def claim
    @invite = Invite.find_by(token: params[:token])
    
    if @invite.nil?
      redirect_to root_path, alert: "Invalid invitation token"
      return
    end
    
    if @invite.expired?
      redirect_to root_path, alert: "This invitation has expired"
      return
    end
    
    # If user is not logged in, store the token and redirect to sign up
    unless user_signed_in?
      session[:invite_token] = params[:token]
      redirect_to new_user_registration_path, notice: "Please sign up or log in to join the team"
      return
    end
    
    # Assign the user to the team
    current_user.team = @invite.team
    if current_user.save
      @invite.destroy # Revoke the invite after successful claim
      redirect_to dashboard_index_path, notice: "You have successfully joined the team!"
    else
      redirect_to root_path, alert: "Failed to join the team"
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:email)
  end
end
