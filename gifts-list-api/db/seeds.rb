require "factory_bot"
require "faker"

FactoryBot.find_definitions

clients = FactoryBot.create_list(:client, Faker::Number.between(from: 1, to: 3))

clients.each do |client|
  FactoryBot.create_list(:list, Faker::Number.between(from: 1, to: 3))
  FactoryBot.create_list(:category, Faker::Number.between(from: 2, to: 3))
  FactoryBot.create_list(:product, Faker::Number.between(from: 7, to: 20))

  products = Product.where(client: client)

  Category.where.not(parent_category_id: nil).each do |subcategory|
    selected_products = products.take(Faker::Number.between(from: 7, to: products.count))

    selected_products.each do |product|
      subcategory.products << product
    end
  end

  List.all.each do |list|
    selected_products = products.take(Faker::Number.between(from: 7, to: products.count))

    selected_products.each do |product|
      list.products << product
    end
  end
end
