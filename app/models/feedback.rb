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
