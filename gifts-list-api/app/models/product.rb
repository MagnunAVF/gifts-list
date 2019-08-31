class Product < ApplicationRecord
  validates_presence_of :name, :price, :client_id
  validates :price, numericality: { greater_than: 0 }

  belongs_to :client
  belongs_to :list
  has_many :product_category_association
  has_many :categories, through: :product_category_association
  has_many :product_list_association
  has_many :lists, through: :product_list_association
end
