class List < ApplicationRecord
  validates_presence_of :name

  belongs_to :client
end
