class Category < ApplicationRecord
  validates_presence_of :name, :client_id

  belongs_to :client
  belongs_to :parent_category, class_name: "Category", foreign_key: "parent_category_id"
  has_many :subcategories, class_name: "Category", foreign_key: "parent_category_id"
  has_many :product_category_association
  has_many :products, through: :product_category_association
end
