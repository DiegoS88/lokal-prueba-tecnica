class CatalogController < ApplicationController
  def index
    @products = Product.available.includes(:provider).order(:name)
  end
end
