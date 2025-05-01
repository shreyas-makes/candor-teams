require 'rails_helper'

RSpec.describe Team, type: :model do
  subject { build(:team) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'ActiveRecord associations' do
    it { should have_many(:users) }
  end

  describe 'ActiveModel validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:max_members).is_greater_than_or_equal_to(1) }
  end
end
