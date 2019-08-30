FactoryBot.define do
    factory :client do
      name   { Faker::Company.name }

      transient do
        posts_count { 5 }
      end
      after(:create) do |client, evaluator|
        create_list(:product, evaluator.posts_count, client: client)
      end
    end
  end