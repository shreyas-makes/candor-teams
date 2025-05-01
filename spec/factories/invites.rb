FactoryBot.define do
  factory :invite do
    association :team
    email { Faker::Internet.email }
    expires_at { 48.hours.from_now }
    token { SecureRandom.uuid }
  end
end 