class Provider < ApplicationRecord
  has_many :products
  has_many :suborders

  validates :name, presence: true
end
