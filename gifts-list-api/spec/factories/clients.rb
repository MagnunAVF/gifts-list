FactoryBot.define do
  factory :client do
    name { Faker::Company.name }

    after(:create) do |client, evaluator|
      create_list(:product, 5, client: client)
    end
  end
end
