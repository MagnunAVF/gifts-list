class Product < ApplicationRecord
  validates_presence_of :name, :price, :client_id
  validates :price, numericality: { greater_than: 0 }

  belongs_to :client
  has_many :product_category_association
  has_many :categories, through: :product_category_association
end
