class Store < ApplicationRecord
  has_many :orders

  validates :name, presence: true
end
