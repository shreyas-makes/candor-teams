FactoryBot.define do
  factory :feedback do
    association :author, factory: :user
    association :recipient, factory: :user
    score { rand(-5..5) }
    comment { Faker::Lorem.paragraph(sentence_count: 3) }
    week_start { Date.current.beginning_of_week }
  end
end
