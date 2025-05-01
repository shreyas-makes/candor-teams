require 'rails_helper'

RSpec.describe 'Team seeds' do
  describe 'running seeds' do
    before(:each) do
      # Clear any existing Demo team
      Team.where(name: 'Demo').destroy_all
      
      # Create test users with no team
      @users = create_list(:user, 3, team_id: nil)
      
      # Load seeds
      load Rails.root.join('db/seeds.rb')
      
      # Reload all users
      @users.each(&:reload)
    end
    
    it 'creates a Demo team' do
      demo_team = Team.find_by(name: 'Demo')
      expect(demo_team).to be_present
      expect(demo_team.max_members).to eq(10)
    end
    
    it 'assigns team_id to previously unassigned users' do
      # All users should now have a team_id
      @users.each do |user|
        expect(user.team_id).to be_present
      end
      
      # All users should have the same team_id
      expect(@users.map(&:team_id).uniq.length).to eq(1)
    end
  end
end 