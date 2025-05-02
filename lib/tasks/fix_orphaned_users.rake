namespace :users do
  desc "Find users without a team and help fix them"
  task find_orphaned: :environment do
    orphaned_users = User.where(team_id: nil)
    
    if orphaned_users.any?
      puts "Found #{orphaned_users.count} users without a team:"
      
      orphaned_users.each do |user|
        puts "- #{user.email} (ID: #{user.id}, Created: #{user.created_at})"
      end
      
      puts "\nTo fix these users, you have options:"
      puts "1. Create a new team and assign users to it:"
      puts "   rake users:create_team_for_orphans"
      puts "2. Assign users to an existing team (replace TEAM_ID with the actual team ID):"
      puts "   rake users:assign_to_team[TEAM_ID]"
    else
      puts "No users without a team found. All users are properly associated with teams."
    end
  end
  
  desc "Create a new team and assign orphaned users to it"
  task create_team_for_orphans: :environment do
    orphaned_users = User.where(team_id: nil)
    
    if orphaned_users.any?
      # Create a new team
      team_name = "Newly Assigned Team - #{Time.current.strftime('%Y-%m-%d')}"
      team = Team.create!(name: team_name, max_members: orphaned_users.count + 5)
      
      puts "Created new team: #{team.name} (ID: #{team.id})"
      
      # Assign all orphaned users to this team
      orphaned_users.each do |user|
        user.update_column(:team_id, team.id)
        puts "Assigned user #{user.email} to team #{team.name}"
      end
      
      puts "\nAll orphaned users have been assigned to the new team."
    else
      puts "No users without a team found. Nothing to do."
    end
  end
  
  desc "Assign orphaned users to an existing team"
  task :assign_to_team, [:team_id] => :environment do |t, args|
    if args[:team_id].blank?
      puts "Error: Team ID is required."
      puts "Usage: rake users:assign_to_team[TEAM_ID]"
      next
    end
    
    team = Team.find_by(id: args[:team_id])
    
    if team.nil?
      puts "Error: Team with ID #{args[:team_id]} not found."
      next
    end
    
    orphaned_users = User.where(team_id: nil)
    
    if orphaned_users.any?
      puts "Found #{orphaned_users.count} users without a team. Assigning to #{team.name} (ID: #{team.id})..."
      
      orphaned_users.each do |user|
        user.update_column(:team_id, team.id)
        puts "Assigned user #{user.email} to team #{team.name}"
      end
      
      puts "\nAll orphaned users have been assigned to the selected team."
    else
      puts "No users without a team found. Nothing to do."
    end
  end
end 