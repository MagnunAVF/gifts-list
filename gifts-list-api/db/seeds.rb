require "factory_bot"
require "faker"

FactoryBot.find_definitions

puts("Creating initial data ...")

puts("Creating clients ...")
clients = FactoryBot.create_list(:client, 3)

clients.each do |client|
  puts("Creating lists for client #{client.name} (id: #{client.id}) ...")
  FactoryBot.create_list(:list, Faker::Number.between(from: 3, to: 7), client: client)
  puts("Creating categories and subcategories for client #{client.name} (id: #{client.id}) ...")
  FactoryBot.create_list(:category, Faker::Number.between(from: 3, to: 10), client: client)
  puts("Creating products for client #{client.name} (id: #{client.id}) ...")
  FactoryBot.create_list(:product, Faker::Number.between(from: 100, to: 300), client: client)

  products = Product.where(client: client)

  puts("Creating product-category associations for client #{client.name} (id: #{client.id}) ...")
  Category.where.not(parent_category_id: nil).each do |subcategory|
    selected_products = products.sample(Faker::Number.between(from: 100, to: products.count))

    selected_products.each do |product|
      subcategory.products << product
    end
  end

  puts("Creating product-list associations for client #{client.name} (id: #{client.id}) ...")
  List.all.each do |list|
    selected_products = products.sample(Faker::Number.between(from: 100, to: products.count))

    selected_products.each do |product|
      list.products << product
    end
  end
end

puts("Success !")
