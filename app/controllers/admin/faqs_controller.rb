class Admin::FaqsController < Admin::BaseController
  before_action :set_faq, only: [:edit, :update, :destroy]

  def index
    @faqs = Faq.includes(:faq_category).order('faq_categories.position ASC, faqs.position ASC')
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to admin_faqs_path, notice: "FAQ问题已创建。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: "FAQ问题已更新。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @faq.destroy
    redirect_to admin_faqs_path, notice: "FAQ问题已删除。"
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer, :faq_category_id, :position)
  end
end
