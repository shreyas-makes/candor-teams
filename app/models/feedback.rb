class Feedback < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :score, inclusion: { in: -5..5 }
  validates :comment, presence: true, length: { in: 1..3000 }
  validates :author_id, uniqueness: { scope: [:recipient_id, :week_start] }
  validate :no_self_feedback

  before_validation :set_week_start

  # Helper method to snap any Date/Time to the UTC-Monday of its week
  def week_start(date = nil)
    date ||= Date.current
    date = date.to_date if date.respond_to?(:to_date)
    # Get the beginning of the week (Monday)
    date.beginning_of_week
  end

  # Class method to snap any Date/Time to the UTC-Monday of its week
  def self.week_start(date = nil)
    date ||= Date.current
    date = date.to_date if date.respond_to?(:to_date)
    # Get the beginning of the week (Monday)
    date.beginning_of_week
  end

  # Generate matrix data for heatmap visualization
  def self.matrix_for(users)
    user_ids = users.pluck(:id)
    
    # Get all feedbacks for the specified users (both as authors and recipients)
    feedbacks = where(author_id: user_ids, recipient_id: user_ids)
                .select(:author_id, :recipient_id, :score)
    
    # Create user info array
    users_array = users.map { |user| { id: user.id, name: user.name } }
    
    # Initialize the matrix data structure
    matrix = Array.new(users.length) { Array.new(users.length, nil) }
    
    # Create a mapping of user IDs to array indices
    user_id_to_index = {}
    users.each_with_index { |user, index| user_id_to_index[user.id] = index }
    
    # Populate the matrix with feedback scores
    feedbacks.each do |feedback|
      from_idx = user_id_to_index[feedback.author_id]
      to_idx = user_id_to_index[feedback.recipient_id]
      
      # Skip if we can't find the indices (shouldn't happen, but just in case)
      next unless from_idx && to_idx
      
      # Store the score in the appropriate cell
      matrix[from_idx][to_idx] = feedback.score
    end
    
    # Return the completed matrix data
    {
      users: users_array,
      matrix: matrix
    }
  end

  private

  def set_week_start
    if self.week_start && self.week_start != self.week_start.beginning_of_week
      self.week_start = week_start(self.week_start)
    end
  end

  def no_self_feedback
    if author_id == recipient_id
      errors.add(:recipient_id, "cannot provide feedback to yourself")
    end
  end
end
