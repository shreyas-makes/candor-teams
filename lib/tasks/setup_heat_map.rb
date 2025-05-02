# Create or find the team
team = Team.find_by(name: "Sample Heat Map Team")
team ||= Team.create!(name: "Sample Heat Map Team", max_members: 10)

puts "Using team: #{team.name} (ID: #{team.id})"

# Sample user data
sample_users = [
  { email: "heat_user1@example.com", password: "password123" },
  { email: "heat_user2@example.com", password: "password123" },
  { email: "heat_user3@example.com", password: "password123" },
  { email: "heat_user4@example.com", password: "password123" },
  { email: "heat_user5@example.com", password: "password123" }
]

created_users = []

# Create or update users
sample_users.each do |user_data|
  user = User.find_by(email: user_data[:email])
  
  if user
    user.update!(
      team_id: team.id,
      paying_customer: true,
      stripe_subscription_id: "sub_#{user_data[:email].split('@').first}"
    )
    puts "Updated user: #{user.email}"
  else
    user = User.create!(
      email: user_data[:email],
      password: user_data[:password],
      password_confirmation: user_data[:password],
      team_id: team.id,
      paying_customer: true,
      stripe_subscription_id: "sub_#{user_data[:email].split('@').first}"
    )
    puts "Created user: #{user.email}"
  end
  
  created_users << user
end

# Clear existing feedback for these users
user_ids = created_users.map(&:id)
feedback_count = Feedback.where(author_id: user_ids).or(Feedback.where(recipient_id: user_ids)).delete_all
puts "Cleared #{feedback_count} existing feedback records"

# Create feedback data
week_start = Date.current.beginning_of_week

created_users.each do |author|
  created_users.each do |recipient|
    next if author.id == recipient.id
    
    # Random score between -5 and 5
    score = rand(-5..5)
    
    Feedback.create!(
      author_id: author.id,
      recipient_id: recipient.id,
      score: score,
      comment: "Heat map test feedback from #{author.email} to #{recipient.email}",
      week_start: week_start
    )
    
    puts "Created feedback: #{author.email} → #{recipient.email}: #{score}"
  end
end

# Final verification
team.reload
puts "\nFinal team verification:"
puts "Team ID: #{team.id}"
puts "Team has #{team.users.count} members:"

team.users.each do |user|
  puts "- #{user.email} (team_id: #{user.team_id})"
end

puts "\nLogin with any of these accounts (password: password123):"
created_users.each do |user|
  puts "- #{user.email}"
end 