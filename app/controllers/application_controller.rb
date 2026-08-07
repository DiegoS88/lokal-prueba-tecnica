class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_store

  # Sin autenticacion (fuera de alcance): se usa siempre la tienda de los datos iniciales.
  def current_store
    @current_store ||= Store.order(:id).first || Store.first!
  end

  # Carrito en session: hash { product_id => cantidad }
  def cart
    session[:cart] ||= {}
  end
  helper_method :cart
end
