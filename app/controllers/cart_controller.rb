class CartController < ApplicationController
  def show
    @products = Product.where(id: cart.keys).includes(:provider)
  end

  def add
    product = available_product
    quantity = requested_quantity
    return unless product && valid_quantity?(quantity)

    target_quantity = cart[product.id.to_s].to_i + quantity
    return unless within_stock?(product, target_quantity)

    cart[product.id.to_s] = target_quantity
    redirect_to cart_path, notice: "Se agregó #{product.name} al carrito."
  end

  def update
    product = cart_product
    quantity = requested_quantity
    return unless product && valid_quantity?(quantity)
    return unless within_stock?(product, quantity)

    cart[product.id.to_s] = quantity
    redirect_to cart_path, notice: "Carrito actualizado."
  end

  def remove
    cart.delete(params[:product_id].to_s)
    redirect_to cart_path, notice: "Producto eliminado del carrito."
  end

  private

  def available_product
    product = Product.available.find_by(id: params[:product_id])
    return product if product

    redirect_with_error("El producto no existe o no tiene stock disponible.")
    nil
  end

  def cart_product
    product_id = params[:product_id].to_s
    unless cart.key?(product_id)
      redirect_to cart_path, alert: "El producto no está en el carrito."
      return nil
    end

    Product.find_by(id: product_id)
  end

  def requested_quantity
    params[:quantity].to_i
  end

  def valid_quantity?(quantity)
    return true if quantity >= 1

    redirect_with_error("La cantidad debe ser un número entero mayor que cero.")
    false
  end

  def within_stock?(product, quantity)
    return true if quantity <= product.stock

    redirect_with_error("No hay suficiente stock de #{product.name} (disponible: #{product.stock}).")
    false
  end

  def redirect_with_error(message)
    redirect_back fallback_location: root_path, alert: message
  end
end
