class Suborder < ApplicationRecord
  belongs_to :order
  belongs_to :provider
  has_many :suborder_items, dependent: :destroy

  validates :subtotal, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :same_provider_products
  validate :subtotal_meets_min_purchase

  def subtotal_in_currency
    subtotal / Currency.divisor
  end

  private

  def same_provider_products
    return if suborder_items.all? { |item| item.product.provider_id == provider_id }

    errors.add(:base, "Todos los productos de una suborden deben pertenecer al mismo proveedor")
  end

  def subtotal_meets_min_purchase
    return if subtotal.nil?
    return if provider.nil? || provider.min_purchase.nil?

    minimum = (provider.min_purchase).round
    return if subtotal >= minimum

    errors.add(:subtotal, "debe ser mayor o igual al monto mínimo del proveedor")
  end
end
