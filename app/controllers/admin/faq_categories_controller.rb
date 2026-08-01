class Admin::FaqCategoriesController < Admin::BaseController
  before_action :set_faq_category, only: [:edit, :update, :destroy]

  def index
    @faq_categories = FaqCategory.order(position: :asc)
  end

  def new
    @faq_category = FaqCategory.new
  end

  def create
    @faq_category = FaqCategory.new(faq_category_params)
    if @faq_category.save
      redirect_to admin_faq_categories_path, notice: "FAQ分类已创建。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @faq_category.update(faq_category_params)
      redirect_to admin_faq_categories_path, notice: "FAQ分类已更新。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @faq_category.destroy
    redirect_to admin_faq_categories_path, notice: "FAQ分类已删除。"
  end

  private

  def set_faq_category
    @faq_category = FaqCategory.find(params[:id])
  end

  def faq_category_params
    params.require(:faq_category).permit(:name, :position)
  end
end
