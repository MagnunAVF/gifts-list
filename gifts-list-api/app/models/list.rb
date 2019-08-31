class List < ApplicationRecord
  validates_presence_of :name

  belongs_to :client
  has_many :product_list_association
  has_many :products, through: :product_list_association
end
