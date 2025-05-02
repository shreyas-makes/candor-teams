require 'rails_helper'

RSpec.describe "Feedbacks", type: :request do
  include Devise::Test::IntegrationHelpers
  
  describe "GET /heat-map" do
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
    
    it "returns a successful response" do
      get heat_map_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Team Feedback Heat Map")
    end
  end

  describe "GET /matrix" do
    let(:user) { create(:user) }
    let(:team) { create(:team, admin_id: user.id) }
    let(:other_user) { create(:user) }
    
    before do
      # Associate users with team
      user.update(team: team)
      other_user.update(team: team)
      
      # Create a feedback
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
    
    it "returns a JSON matrix of feedbacks" do
      get matrix_path(format: :json)
      expect(response).to have_http_status(:success)
      
      # Parse the JSON response
      json = JSON.parse(response.body)
      
      # Verify the response structure
      expect(json).to include("users", "matrix")
      expect(json["users"]).to be_an(Array)
      expect(json["matrix"]).to be_an(Array)
      
      # Verify the content
      expect(json["users"].length).to eq(2) # user and other_user
      expect(json["matrix"].length).to eq(2) # 2x2 matrix
    end
  end
end 