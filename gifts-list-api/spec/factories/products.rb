FactoryBot.define do
  factory :product do
    name { Faker::Vehicle.make_and_model }
    description { Faker::Books::Lovecraft.sentence }
    price { Faker::Number.decimal(l_digits: 2) }
    client
  end
end
