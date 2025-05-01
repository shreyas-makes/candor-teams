class Team < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :max_members, numericality: { greater_than_or_equal_to: 1 }
end
