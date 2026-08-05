class Admin::OrdersController < Admin::BaseController
  def index
    @orders = Order.order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
    @order = Order.includes(order_items: :sku).find(params[:id])
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to admin_orders_path, notice: "订单已删除"
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "订单状态已更新"
    else
      redirect_to admin_order_path(@order), alert: "订单状态更新失败"
    end
  end

  private

  def order_params
    params.require(:order).permit(:status)
  end
end
