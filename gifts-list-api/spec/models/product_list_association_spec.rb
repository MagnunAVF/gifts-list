require "spec_helper"

RSpec.describe ProductListAssociation, type: :model do
  context "When associating a product to a category" do
    it "should set correct references" do
      list = create(:list)
      products = create_list(:product, 7)

      products.each do |product|
        list.products << product
      end

      products.each do |product|
        expect(product.lists.first.id).to be(list.id)
      end
    end
  end
end
