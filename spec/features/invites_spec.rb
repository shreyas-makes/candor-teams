require 'rails_helper'

RSpec.describe 'Invites', type: :feature do
  include Devise::Test::IntegrationHelpers
  
  let(:team) { create(:team) }
  let(:admin) { create(:user, email: "admin@example.com", password: "password", team: team, admin: true) }
  let(:invite_email) { 'newuser@example.com' }
  
  before do
    sign_in admin
  end

  it 'admin can send an invite and visitor can claim it' do
    # Admin sends invite
    visit dashboard_index_path
    
    within('#invite-form') do
      fill_in 'invite[email]', with: invite_email
      click_button 'Send Invite'
    end
    
    expect(page).to have_content("Invitation sent to #{invite_email}")
    
    # Get the token from the last invite
    invite = Invite.last
    expect(invite.email).to eq(invite_email)
    
    # Logout admin
    sign_out admin
    
    # Visitor visits claim link
    visit claim_invites_path(invite.token)
    
    # Should redirect to sign up
    expect(page).to have_content('Please sign up or log in to join the team')
    expect(current_path).to eq(new_user_registration_path)
    
    # Sign up as new user
    fill_in 'user[email]', with: invite_email
    fill_in 'user[password]', with: 'password123'
    fill_in 'user[password_confirmation]', with: 'password123'
    click_button 'Sign up'
    
    # Should be redirected to dashboard with success message
    expect(page).to have_content('You have successfully joined the team!')
    expect(current_path).to eq(dashboard_index_path)
    
    # Invite should be deleted
    expect(Invite.find_by(id: invite.id)).to be_nil
    
    # New user should be part of the team
    user = User.find_by(email: invite_email)
    expect(user.team).to eq(team)
  end
end 