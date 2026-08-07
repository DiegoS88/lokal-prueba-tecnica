class OrdersController < ApplicationController
  def create
    service = Orders::Create.new(store: current_store, lines: cart)

    order = service.call

    if order
      session[:cart] = {}
      redirect_to order, notice: "Compra confirmada. Tu orden fue creada correctamente."
    else
      redirect_to cart_path, alert: service.errors.join(" ")
    end
  end

  def show
    @order = Order.includes(suborders: :suborder_items).find(params[:id])
  end
end
