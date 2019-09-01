class List < ApplicationRecord
  validates_presence_of :name, :client_id

  belongs_to :client
  has_many :product_list_association
  has_many :products, through: :product_list_association

  def as_json(options = {})
    super(only: [:id, :name])
  end
end
