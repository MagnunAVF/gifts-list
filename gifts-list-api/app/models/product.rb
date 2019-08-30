class Product < ApplicationRecord
    belongs_to :client

    validates_presence_of :name, :price, :client_id
    validates :price, numericality: { greater_than: 0 }
end
