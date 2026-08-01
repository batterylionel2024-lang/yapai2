class SkusController < ApplicationController
  def show
    @sku = Sku.includes(category: { parent: { parent: :parent } }).find_by(id: params[:id])
    
    if @sku.nil?
      redirect_to products_path, alert: t('categories.no_skus_title')
      return
    end

    @kind = @sku.category.category_kind
  end
end
