require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'ActiveRecord associations' do
    it { should belong_to(:team).optional }
  end

  describe 'ActiveModel validations' do
    it { expect(subject).to validate_presence_of(:email) }
  end
end
