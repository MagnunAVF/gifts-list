FactoryBot.define do
  factory :category do
    name { Faker::Games::ElderScrolls.creature }
    client

    trait :with_subcategories do
      after(:create) do |category, evaluator|
        create_list(:category, 5, parent_category: category)
      end
    end
  end
end
