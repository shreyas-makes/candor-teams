class RegistrationsController < Devise::RegistrationsController
  before_action :protect_from_spam, only: [:create]
  
  protected
  
  def after_sign_up_path_for(resource)
    process_invite(resource)
    super(resource)
  end
  
  def after_sign_in_path_for(resource)
    process_invite(resource)
    super(resource)
  end
  
  private
  
  def process_invite(user)
    token = session.delete(:invite_token)
    return unless token.present?
    
    invite = Invite.find_by(token: token)
    return unless invite.present? && !invite.expired?
    
    user.team = invite.team
    if user.save
      invite.destroy
      flash[:notice] = "You have successfully joined the team!"
    end
  end
end
