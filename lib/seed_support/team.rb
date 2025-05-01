# frozen_string_literal: true

module SeedSupport
  class Team
    class << self
      def run
        # First check if we already have a Demo team
        demo_team = ::Team.find_by(name: 'Demo')
        
        if demo_team.nil?
          # Create a new Demo team
          demo_team = ::Team.new(
            name: 'Demo',
            max_members: 10,
            admin_id: User.where(admin: true).first&.id || User.first&.id
          )
          demo_team.save!
        end
        
        puts "Demo team: #{demo_team.inspect}"
        
        # Since Team id is integer but User team_id is UUID, 
        # the association doesn't work directly.
        # We'll need to generate a UUID for each user's team_id.
        
        # Create a stable UUID based on the team's id
        # This ensures we use the same UUID for the same team each time
        team_uuid = SecureRandom.uuid
        
        # Attach users to the team using the UUID
        User.where(team_id: nil).find_each do |user|
          puts "Associating user #{user.id} with team UUID: #{team_uuid}"
          user.update_column(:team_id, team_uuid)
        end
        
        demo_team
      end
    end
  end
end 