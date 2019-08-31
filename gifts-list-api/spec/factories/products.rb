FactoryBot.define do
  factory :product do
    name { Faker::Games::Zelda.item }
    description { Faker::Books::Lovecraft.sentence }
    price { Faker::Number.decimal(l_digits: 2) }
    client
  end
end
