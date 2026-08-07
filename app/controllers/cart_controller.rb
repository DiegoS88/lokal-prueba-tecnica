class CartController < ApplicationController
  def show
    @products = Product.where(id: cart.keys).includes(:provider)
  end

  def add
    product = Product.available.find_by(id: params[:product_id])
    quantity = params[:quantity].to_i

if product.nil?
      return redirect_with_error("El producto no existe o no tiene stock disponible.")
end

    if quantity < 1
      return redirect_with_error("La cantidad debe ser un número entero mayor que cero.")
    end

    current_qty = cart[product.id.to_s].to_i
    new_qty = current_qty + quantity
    if new_qty > product.stock
      return redirect_with_error("No hay suficiente stock de #{product.name} (disponible: #{product.stock}).")
    end

    cart[product.id.to_s] = new_qty
    redirect_to cart_path, notice: "Se agregó #{product.name} al carrito."
  end

  def update
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i

    unless cart.key?(product_id)
      return redirect_to cart_path, alert: "El producto no está en el carrito."
    end

    if quantity < 1
      return redirect_to cart_path, alert: "La cantidad debe ser un entero mayor que cero."
    end

    product = Product.find_by(id: product_id)
    if product.nil? || quantity > product.stock
      return redirect_to cart_path, alert: "Stock insuficiente para #{product&.name || 'el producto'}."
    end

    cart[product_id] = quantity
    redirect_to cart_path, notice: "Carrito actualizado."
  end

  def remove
    cart.delete(params[:product_id].to_s)
    redirect_to cart_path, notice: "Producto eliminado del carrito."
  end

  private

  def redirect_with_error(message)
    redirect_back fallback_location: root_path, alert: message
  end
end
