class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.unscoped.where(parent_id: nil).order(:position, :id).includes(:children)
  end

  def show
  end

  def new
    if params[:parent_id].present?
      parent = Category.find(params[:parent_id])
      @category = Category.new(parent_id: parent.id, category_kind: parent.category_kind)
    else
      @category = Category.new
    end
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: '分类创建成功。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: '分类更新成功。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: '分类已删除。'
  end

  private

  def set_category
    @category = Category.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :slug, :parent_id, :category_kind, :hidden, :position, :featured, :featured_position, :image, :meta_title, :meta_description, :meta_keywords, :keywords)
  end
end
