FactoryBot.define do
  factory :team do
    name { Faker::Team.name }
    max_members { 5 }
    admin_id { create(:user).id }
  end
end
