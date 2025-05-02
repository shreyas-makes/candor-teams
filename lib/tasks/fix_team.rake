namespace :fix_team do
  desc "Create a new team and associate sample users with it"
  task create_team: :environment do
    # Create a new team
    team = Team.create!(name: "Sample Team (New)", max_members: 10)
    puts "Created new team: #{team.name} (ID: #{team.id})"

    # List of sample user emails
    sample_emails = [
      "user1@example.com",
      "user2@example.com", 
      "user3@example.com",
      "user4@example.com",
      "user5@example.com"
    ]
    
    # Find existing users or create new ones
    sample_emails.each do |email|
      user = User.find_by(email: email)
      if user
        # Use update_column to bypass any callbacks
        user.update_column(:team_id, team.id)
        puts "Updated existing user: #{email} with new team_id: #{team.id}"
      else
        # Create a new user
        new_user = User.new(
          email: email,
          password: "password123",
          password_confirmation: "password123",
          paying_customer: true,
          stripe_subscription_id: "sample_sub_#{email.split('@').first}"
        )
        new_user.team_id = team.id
        new_user.save!
        puts "Created new user: #{email} with team_id: #{team.id}"
      end
    end
    
    # Verify team members
    team.reload
    puts "\nVerifying team members:"
    team.users.each do |user|
      puts "- #{user.email} (ID: #{user.id})"
    end
    
    # Create sample feedback data
    puts "\nCreating feedback data..."
    
    # First, clean up any existing feedback
    user_ids = User.where(email: sample_emails).pluck(:id)
    Feedback.where(author_id: user_ids).or(Feedback.where(recipient_id: user_ids)).delete_all
    
    # Get the Monday of the current week
    week_start = Date.current.beginning_of_week
    
    # Get all users
    users = User.where(email: sample_emails).to_a
    
    # Create feedback between all users (except self-feedback)
    users.each do |author|
      users.each do |recipient|
        next if author == recipient # Skip self-feedback
        
        # Generate a random score between -5 and 5
        score = rand(-5..5)
        
        # Create feedback
        feedback = Feedback.create!(
          author: author,
          recipient: recipient,
          score: score,
          comment: "This is sample feedback from #{author.email} to #{recipient.email}.",
          week_start: week_start
        )
        
        puts "Created feedback: #{author.email} → #{recipient.email}: #{score}"
      end
    end
    
    puts "\nSetup completed! You can now log in with any of these accounts:"
    sample_emails.each do |email|
      puts "- Email: #{email}"
      puts "  Password: password123"
    end
  end

  desc "Test heat map access"
  task test_access: :environment do
    # Pick a sample user
    user = User.find_by(email: "user1@example.com")
    
    if user
      puts "Test user: #{user.email}"
      puts "Team ID: #{user.team_id}"
      
      if user.team
        puts "Team name: #{user.team.name}"
        puts "Team users count: #{user.team.users.count}"
        
        if user.team.users.any?
          puts "Heat map access should work!"
        else
          puts "Heat map access will fail - team has no users"
        end
      else
        puts "Heat map access will fail - user has no team"
      end
    else
      puts "Sample user not found. Run fix_team:create_team first."
    end
  end
end 