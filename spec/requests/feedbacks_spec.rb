require 'rails_helper'

RSpec.describe "Feedbacks", type: :request do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team) }
  let(:other_users) { create_list(:user, 3, team: team) }
  
  before do
    # Create some feedback data
    other_users.each do |recipient|
      create(:feedback, author: user, recipient: recipient, score: rand(-5..5))
    end
  end

  describe "GET /matrix" do
    context "when user is authenticated" do
      before do
        sign_in user
        get "/matrix"
      end
      
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
      
      it "returns JSON with expected structure" do
        json = JSON.parse(response.body)
        
        # Check for required keys
        expect(json).to have_key("users")
        expect(json).to have_key("feedback_data")
        
        # Check that users is an array with expected length
        expect(json["users"]).to be_an(Array)
        expect(json["users"].length).to eq(4) # Original user + 3 team members
        
        # Check that feedback_data has entries
        expect(json["feedback_data"]).to be_a(Hash)
        expect(json["feedback_data"].keys).to include(user.id.to_s)
      end
    end
    
    context "when user is not authenticated" do
      it "redirects to login page" do
        get "/matrix"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end 