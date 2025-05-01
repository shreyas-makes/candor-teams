FactoryBot.define do
  factory :user do
    sequence(:id) { |n| n }
    email { Faker::Internet.email }
    password { 'password' }
    paying_customer { false }
  end
end
