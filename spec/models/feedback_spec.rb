require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it { should belong_to(:author).class_name('User') }
    it { should belong_to(:recipient).class_name('User') }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:score).in_range(-5..5) }
    it { should validate_presence_of(:comment) }
    it { should validate_length_of(:comment).is_at_least(1).is_at_most(3000) }

    describe 'self-feedback validation' do
      let(:user) { create(:user) }
      let(:feedback) { build(:feedback, author: user, recipient: user) }

      it 'disallows feedback to self' do
        expect(feedback).not_to be_valid
        expect(feedback.errors[:recipient_id]).to include("cannot provide feedback to yourself")
      end
    end
  end

  describe '#week_start method' do
    let(:feedback) { build(:feedback) }
    
    it 'snaps a date to its Monday' do
      # Tuesday
      date = Date.new(2025, 5, 6)
      expect(feedback.week_start(date)).to eq(Date.new(2025, 5, 5))
      
      # Sunday
      date = Date.new(2025, 5, 11)
      expect(feedback.week_start(date)).to eq(Date.new(2025, 5, 5))
    end

    it 'converts Time to Date' do
      time = Time.new(2025, 5, 7, 15, 30, 0)
      expect(feedback.week_start(time)).to eq(time.to_date.beginning_of_week)
    end

    it 'uses current date if none provided' do
      current_monday = Date.current.beginning_of_week
      expect(feedback.week_start).to eq(current_monday)
    end
  end

  describe 'uniqueness constraint' do
    let(:author) { create(:user) }
    let(:recipient) { create(:user) }
    let(:current_week) { Date.current.beginning_of_week }
    
    before do
      @feedback = create(:feedback, author: author, recipient: recipient, week_start: current_week)
    end

    it 'prevents duplicate feedback for same author, recipient, and week' do
      duplicate = build(:feedback, author: author, recipient: recipient, week_start: current_week)
      expect(duplicate).not_to be_valid
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows feedback for same author and recipient in different weeks' do
      next_week = (current_week + 7.days)
      feedback = build(:feedback, author: author, recipient: recipient, week_start: next_week)
      expect(feedback).to be_valid
    end
  end
end
