namespace :sample_data do
  desc "Create a sample team with users and feedback data for testing"
  task create: :environment do
    # Create a sample team
    team = Team.create!(name: "Sample Team", max_members: 10)
    puts "Created team: #{team.name} (ID: #{team.id})"

    # Create sample users in the team
    user_emails = [
      "user1@example.com",
      "user2@example.com", 
      "user3@example.com",
      "user4@example.com",
      "user5@example.com"
    ]

    users = user_emails.map do |email|
      username = email.split('@').first
      
      # First check if user already exists
      user = User.find_by(email: email)
      
      if user
        # Update existing user
        user.update!(
          team_id: team.id,
          paying_customer: true,
          stripe_subscription_id: "sample_sub_#{username}"
        )
        puts "Updated user: #{user.email} with team_id: #{team.id}"
      else
        # Create new user
        user = User.create!(
          email: email,
          password: "password123",
          password_confirmation: "password123",
          team_id: team.id,
          paying_customer: true,
          stripe_subscription_id: "sample_sub_#{username}"
        )
        puts "Created user: #{user.email} with team_id: #{team.id}"
      end
      
      user
    end

    # Explicitly update users' team_id to ensure they're associated
    users.each do |user|
      if user.team_id.nil?
        user.update!(team_id: team.id)
        puts "Fixed team association for #{user.email}"
      end
    end

    # Delete any existing feedback between these users
    user_ids = users.map(&:id)
    existing_feedback = Feedback.where(author_id: user_ids, recipient_id: user_ids)
    if existing_feedback.any?
      existing_feedback.delete_all
      puts "Deleted #{existing_feedback.count} existing feedback entries"
    end

    # Create sample feedback data
    puts "\nCreating feedback data..."
    
    # Get the Monday of the current week
    week_start = Date.current.beginning_of_week
    
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

    puts "\nSample data creation completed!"
    puts "\nLogin with any of these accounts (password: password123):"
    users.each do |user|
      puts "- #{user.email}"
    end
  end

  desc "Reset and recreate sample data"
  task reset: :environment do
    puts "Removing existing sample data..."
    
    # First, find and delete all feedback records
    team = Team.find_by(name: "Sample Team")
    if team
      user_ids = User.where(team_id: team.id).pluck(:id)
      if user_ids.any?
        feedback_count = Feedback.where(author_id: user_ids).or(Feedback.where(recipient_id: user_ids)).delete_all
        puts "Deleted #{feedback_count} feedback entries"
      end
    end
    
    # Delete all users with sample emails
    sample_emails = [
      "user1@example.com",
      "user2@example.com", 
      "user3@example.com",
      "user4@example.com",
      "user5@example.com"
    ]
    
    deleted_users = User.where(email: sample_emails).delete_all
    puts "Deleted #{deleted_users} sample users"
    
    # Delete sample team
    if team
      team.destroy
      puts "Deleted sample team"
    else
      puts "No sample team found"
    end
    
    # Recreate the data
    Rake::Task["sample_data:create"].invoke
  end
end 