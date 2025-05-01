class InviteMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invite_mailer.new_invite.subject
  #
  def new_invite(invite)
    @invite = invite
    @team = invite.team
    @expires_at = invite.expires_at.strftime("%B %d, %Y at %I:%M %p %Z")
    
    mail(
      to: invite.email,
      subject: "You've been invited to join #{@team.name} on Candor Teams"
    )
  end
end
