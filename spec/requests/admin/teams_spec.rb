require 'rails_helper'

RSpec.describe "Admin Teams", type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:team) { create(:team, name: "Original Team Name") }

  before do
    # Sign in the admin user (using Devise test helpers)
    post "/users/sign_in", params: { user: { email: admin.email, password: "password" } }
  end

  describe "PUT /admin/teams/:id" do
    it "updates the team name" do
      # First get the edit page
      get "/admin/teams/#{team.id}/edit"
      expect(response).to have_http_status(:success)
      
      # Then update the team
      put "/admin/teams/#{team.id}", params: {
        team: {
          name: "Updated Team Name",
          max_members: team.max_members
        }
      }
      
      # Should redirect after successful update
      expect(response).to redirect_to(admin_team_path(team))
      
      # Verify the database change
      team.reload
      expect(team.name).to eq("Updated Team Name")
    end
  end
end 