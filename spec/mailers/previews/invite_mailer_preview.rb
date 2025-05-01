# Preview all emails at http://localhost:3000/rails/mailers/invite_mailer
class InviteMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/invite_mailer/new_invite
  def new_invite
    team = Team.first || FactoryBot.create(:team, name: "Preview Team")
    invite = Invite.first || FactoryBot.create(:invite, team: team)
    
    InviteMailer.new_invite(invite)
  end

end
