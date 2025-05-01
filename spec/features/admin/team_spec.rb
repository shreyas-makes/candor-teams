require 'rails_helper'

feature 'Admin Panel Team Management', type: :feature do
  # Avoid JS test to prevent Redis errors
  # include DeviseHelpers

  let!(:admin_user) { create(:user, admin: true) }
  let!(:team) { create(:team, name: 'Original Team Name') }

  scenario 'Admin can edit team name' do
    # Login as admin
    visit new_user_session_path
    fill_in 'user_email', with: admin_user.email
    fill_in 'user_password', with: 'password'
    click_button 'Login'

    # Navigate to admin panel
    visit '/admin'
    expect(page).to have_content('Dashboard')

    # Navigate to teams section
    click_link 'Teams'
    expect(page).to have_content('Teams')
    expect(page).to have_content(team.name)

    # Click edit on the team
    within "tr#team_#{team.id}" do
      first(:link, 'Edit').click
    end

    # Edit the team name
    fill_in 'Name', with: 'Updated Team Name'
    click_button 'Update Team'

    # Verify success message and updated name
    expect(page).to have_content('Team was successfully updated')
    expect(page).to have_content('Updated Team Name')

    # Verify the change persisted in the database
    expect(team.reload.name).to eq('Updated Team Name')
  end
end 