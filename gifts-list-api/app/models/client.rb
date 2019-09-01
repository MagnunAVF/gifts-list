class Client < ApplicationRecord
  validates_presence_of :name

  has_many :products
  has_many :categories
  has_many :lists

  def as_json(options = {})
    super(only: [:id, :name])
  end
end
