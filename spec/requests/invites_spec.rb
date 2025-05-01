require 'rails_helper'

RSpec.describe "Invites", type: :request do
  let(:team) { create(:team) }
  let(:admin_user) { create(:user, email: "admin@example.com", password: "password", team: team, admin: true) }
  let(:regular_user) { create(:user, email: "user@example.com", password: "password") }
  let(:invite_email) { "test@example.com" }
  let(:valid_params) { { invite: { email: invite_email } } }

  describe "POST /invites" do
    context "when user is authenticated and an admin" do
      before do
        sign_in admin_user
      end

      it "creates a new invite" do
        expect {
          post invites_path, params: valid_params
        }.to change(Invite, :count).by(1)
        
        expect(response).to redirect_to(dashboard_index_path)
        expect(flash[:notice]).to include("Invitation sent to #{invite_email}")
      end

      it "enqueues an email job" do
        expect {
          post invites_path, params: valid_params
        }.to have_enqueued_job.on_queue('mailers')
      end

      it "sets the team correctly" do
        post invites_path, params: valid_params
        expect(Invite.last.team).to eq(team)
      end
    end

    context "when user is not authenticated" do
      it "redirects to login page" do
        post invites_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is not authorized" do
      before do
        sign_in regular_user
      end

      it "returns unauthorized" do
        post invites_path, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end

  describe "GET /invites/claim/:token" do
    let!(:invite) { create(:invite, team: team, email: invite_email) }

    context "when token is valid" do
      it "renders the claim page for unauthenticated users" do
        get claim_invites_path(invite.token)
        expect(response).to redirect_to(new_user_registration_path)
        expect(session[:invite_token]).to eq(invite.token)
      end

      context "when user is authenticated" do
        before do
          sign_in regular_user
          # Make sure we don't have a team already
          regular_user.update(team: nil)
        end

        it "assigns user to the team and deletes the invite" do
          expect {
            get claim_invites_path(invite.token)
          }.to change(Invite, :count).by(-1)
          
          expect(regular_user.reload.team).to eq(team)
          expect(response).to redirect_to(dashboard_index_path)
          expect(flash[:notice]).to include("successfully joined the team")
        end
      end
    end

    context "when token is invalid" do
      it "redirects with an error message" do
        get claim_invites_path("invalid-token")
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Invalid invitation token")
      end
    end

    context "when invite has expired" do
      let!(:expired_invite) { create(:invite, team: team, email: invite_email, expires_at: 2.days.ago) }

      it "redirects with an error message" do
        get claim_invites_path(expired_invite.token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("This invitation has expired")
      end
    end
  end
end
