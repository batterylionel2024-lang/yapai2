class CategoriesController < ApplicationController
  def index
    @kind = params[:kind]
    
    # 安全检查: 只允许指定频道，防止 Dangerous Send 漏洞
    unless @kind.nil? || %w[apple huawei oppo vivo xiaomi custom].include?(@kind)
      redirect_to categories_path, alert: "无效的分类频道"
      return
    end

    @categories = Category.visible.where(parent_id: nil).includes(children: { children: { children: :children } })
    
    if @kind.present?
      @categories = @categories.where(category_kind: @kind)
    end
    
    if params[:category_id].present?
      begin
        @current_category = Category.visible.includes(parent: { parent: :parent }).find_by(slug: params[:category_id])
        @current_category ||= Category.visible.includes(parent: { parent: :parent }).find(params[:category_id])
        
        @skus = @current_category.all_descendant_skus.where(status: 'active').includes(:category, images_attachments: :blob)
        
        if params[:q].present?
          @skus = @skus.where("LOWER(name) LIKE ?", "%#{params[:q].downcase}%")
        end

        @skus = @skus.page(params[:page]).per(20)
      rescue ActiveRecord::RecordNotFound
        redirect_to categories_path, alert: "未找到指定的分类"
        return
      end
    else
      @skus = Sku.joins(:category).where(categories: { hidden: false }, status: 'active').includes(:category, images_attachments: :blob).order(position: :asc, created_at: :desc)
      
      if @kind.present?
        @skus = @skus.where(categories: { category_kind: @kind })
      end

      if params[:q].present?
        @skus = @skus.where("LOWER(skus.name) LIKE ?", "%#{params[:q].downcase}%")
      end

      @skus = @skus.page(params[:page]).per(20)
    end
  end

  def show
    @category = Category.find_by(slug: params[:id]) || Category.find(params[:id])
    redirect_to categories_path(category_id: @category.slug.presence || @category.id)
  end
end
