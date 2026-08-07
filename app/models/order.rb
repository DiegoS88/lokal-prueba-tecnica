class Order < ApplicationRecord
  belongs_to :store
  has_many :order_items, dependent: :destroy
  has_many :suborders, dependent: :destroy

  validates :total, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def total_in_currency
    total / Currency.divisor
  end
end
