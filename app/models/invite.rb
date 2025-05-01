class Invite < ApplicationRecord
  belongs_to :team

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true

  before_create :generate_token
  before_create :set_expiration

  def expired?
    expires_at < Time.current
  end

  private

  def generate_token
    self.token = SecureRandom.uuid unless token.present?
  end

  def set_expiration
    self.expires_at = 48.hours.from_now unless expires_at.present?
  end
end 