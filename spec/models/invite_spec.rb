require 'rails_helper'

RSpec.describe Invite, type: :model do
  subject { build(:invite) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'ActiveRecord associations' do
    it { should belong_to(:team) }
  end

  describe 'ActiveModel validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
    
    context 'email format validation' do
      it 'is valid with correctly formatted email' do
        subject.email = 'valid@example.com'
        expect(subject).to be_valid
      end

      it 'is invalid with incorrectly formatted email' do
        subject.email = 'invalid-email'
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'callbacks' do
    it 'generates a UUID token on create when none exists' do
      invite = build(:invite, token: nil)
      # Call the private method directly to test token generation
      invite.send(:generate_token)
      expect(invite.token).to be_present
      expect(invite.token).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    end

    it 'sets expiration to 48 hours from creation when none exists' do
      invite = build(:invite, expires_at: nil)
      invite.send(:set_expiration)
      expect(invite.expires_at).to be_present
      expect(invite.expires_at).to be_within(2.seconds).of(48.hours.from_now)
    end
  end

  describe '#expired?' do
    it 'returns true when invitation has expired' do
      invite = build(:invite, expires_at: 1.hour.ago)
      expect(invite.expired?).to be true
    end

    it 'returns false when invitation has not expired' do
      invite = build(:invite, expires_at: 1.hour.from_now)
      expect(invite.expired?).to be false
    end
  end

  describe 'token uniqueness' do
    it 'validates token uniqueness' do
      # Create the first invite
      original_token = SecureRandom.uuid
      create(:invite, token: original_token)
      
      # Try to create another invite with the same token
      duplicate = build(:invite, token: original_token)
      
      # It should not be valid due to uniqueness validation
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:token]).to include("has already been taken")
    end
  end
end 