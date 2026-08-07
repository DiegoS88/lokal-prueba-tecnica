class CatalogController < ApplicationController
  def index
    @providers = Provider.order(:name)
    @products = Product.available.includes(:provider).order(:name)
    apply_provider_filter if params[:provider_id].present?
  end

  private

  def apply_provider_filter
    @provider = Provider.find_by(id: params[:provider_id])
    @products = @products.where(provider: @provider) if @provider
  end
end
