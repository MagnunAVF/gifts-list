FactoryBot.define do
  factory :client do
    name { Faker::Company.name }

    after(:create) do |client, evaluator|
      create_list(:product, 5, client: client)
      create_list(:list, 3, client: client)
    end
  end
end
