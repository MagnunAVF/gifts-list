FactoryBot.define do
  factory :list do
    name { Faker::Games::Zelda.location }
    client
  end
end
