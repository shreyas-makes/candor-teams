require 'rails_helper'

RSpec.describe "Heat Map", type: :system, js: true do
  include Devise::Test::IntegrationHelpers
  
  let(:user) { create(:user) }
  let(:team) { create(:team, admin_id: user.id) }
  let(:other_user) { create(:user) }
  
  before do
    # Associate users with team
    user.update(team: team)
    other_user.update(team: team)
    
    # Ensure we have at least one feedback in the system
    create(:feedback, 
      author: user, 
      recipient: other_user, 
      score: 3, 
      comment: "Great work!",
      week_start: Feedback.week_start(Time.current)
    )
    
    # Log in the user
    sign_in user
  end
  
  it "displays the heat map canvas" do
    visit heat_map_path
    
    # Check for main elements
    expect(page).to have_content("Team Feedback Heat Map")
    expect(page).to have_css("canvas#heatmap")
    
    # Verify data attributes
    canvas = find("canvas#heatmap")
    expect(canvas["data-url"]).to eq(matrix_path(format: :json))
    
    # We can't directly test canvas rendering in system tests,
    # but we can check that the controller is attached
    expect(page).to have_css("[data-controller='heatmap']")
  end
end 