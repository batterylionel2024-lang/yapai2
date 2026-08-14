class OrdersController < ApplicationController
  def add_item
    sku = Sku.find(params[:sku_id])
    session[:cart] ||= {}
    session[:cart][sku.id.to_s] = (session[:cart][sku.id.to_s] || 0) + 30
    render json: { count: session[:cart].values.sum }
  end

  def remove_item
    sku_id = params[:sku_id].to_s
    session[:cart] ||= {}
    session[:cart].delete(sku_id)
    render json: { count: session[:cart].values.sum }
  end

  def update_item
    sku_id = params[:sku_id].to_s
    quantity = params[:quantity].to_i
    session[:cart] ||= {}
    if quantity > 0
      session[:cart][sku_id] = quantity
    else
      session[:cart].delete(sku_id)
    end
    render json: { count: session[:cart].values.sum }
  end

  def cart_items
    cart = session[:cart] || {}
    skus = Sku.where(id: cart.keys)
    render json: {
      items: skus.map { |sku| { id: sku.id, name: sku.product_name, quantity: cart[sku.id.to_s] } },
      count: cart.values.sum
    }
  end

  def create
    @order = Order.new(order_params)
    @order.status = 'pending'
    if @order.save
      session[:cart].each do |sku_id, quantity|
        @order.order_items.create!(sku_id: sku_id, quantity: quantity)
      end
      session[:cart] = {}
      render json: { success: true, message: "Order submitted successfully!" }
    else
      render json: { success: false, message: "Failed to submit order, please check your information." }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.permit(:name, :country, :phone, :email)
  end
end
