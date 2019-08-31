require "spec_helper"

RSpec.describe ProductCategoryAssociation, type: :model do
  context "When associating a product to a category" do
    it "should set correct references" do
      parent_category = create(:category, :with_subcategories)
      subcategory = parent_category.subcategories.last
      product = create(:product)

      subcategory.products << product

      expect(subcategory.products.first.id).to be(product.id)
      expect(product.categories.first.id).to be(subcategory.id)
    end
  end
end
