module Orders
  # Crea una orden con todas sus subordenes e items de forma atomica.
  #
  # Recibe un store y un hash de lineas en la forma { product_id => quantity }.
  # Toda la operacion corre dentro de una transaccion: si algo falla (stock
  # insuficiente, cantidad invalida, producto inexistente) no queda ninguna
  # orden ni suborden a medio crear y el stock no se descuenta.
  class Create
    attr_reader :errors

    def initialize(store:, lines:)
      @store = store
      @lines = lines.reject { |_id, q| q.to_i <= 0 }
      @errors = []
    end

    # Retorna la Order creada en caso de exito, o nil si la operacion fallo.
    # Los errores quedan disponibles via #errors.
    def call
      raise ArgumentError, "El carrito está vacío" if @lines.empty?

      ActiveRecord::Base.transaction do
        products = lock_and_build_items!
        order = Order.new(store: @store, total: sum_total(@items))
        order.save!
        persist_items!(order)
        persist_suborders!(order)
        decrement_stock!(products)
        order
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError => e
      @errors << e.message
      nil
    end

    private

    # Bloquea los productos, valida stock y construye los items (sin persistir).
    # Retorna los productos para descontar stock al final.
    def lock_and_build_items!
      @items = @lines.map do |product_id, quantity|
        product = Product.lock.find(product_id)
        if product.stock < quantity
          raise ArgumentError, "Stock insuficiente para #{product.name} (disponible: #{product.stock})"
        end

        {
          product: product,
          quantity: quantity,
          unit_price: product.price,
          line_total: product.price * quantity
        }
      end
      @items.map { |item| item[:product] }
    end

    def persist_items!(order)
      @items.each do |item|
        order.order_items.create!(
          product: item[:product],
          quantity: item[:quantity],
          unit_price: item[:unit_price],
          line_total: item[:line_total]
        )
      end
    end

    def persist_suborders!(order)
      @items.group_by { |item| item[:product].provider_id }.each do |provider_id, provider_items|
        suborder = order.suborders.create!(
          provider_id: provider_id,
          subtotal: provider_items.sum { |item| item[:line_total] }
        )
        provider_items.each do |item|
          suborder.suborder_items.create!(
            product: item[:product],
            quantity: item[:quantity],
            unit_price: item[:unit_price],
            line_total: item[:line_total]
          )
        end
      end
    end

    def decrement_stock!(products)
      products.each do |product|
        product.decrement!(:stock, line_quantity_for(product))
      end
    end

    def line_quantity_for(product)
      (@lines[product.id] || @lines[product.id.to_s] || 0).to_i
    end

    def sum_total(items)
      items.sum { |item| item[:line_total] }
    end
  end
end
