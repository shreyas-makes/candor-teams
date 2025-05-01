require 'rails_helper'

RSpec.describe TeamPolicy, type: :policy do
  describe "#update?" do
    let(:user) { double("User", id: 123) }
    let(:admin_user) { double("User", id: 123) }
    let(:non_admin_user) { double("User", id: 456) }
    let(:team) { double("Team", admin_id: 123) }
    
    context "when user is the admin of the team" do
      it "allows access" do
        policy = TeamPolicy.new(admin_user, team)
        expect(policy.update?).to be true
      end
    end

    context "when user is not the admin of the team" do
      it "denies access" do
        policy = TeamPolicy.new(non_admin_user, team)
        expect(policy.update?).to be false
      end
    end
  end
end
