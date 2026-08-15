class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: [:edit, :update, :destroy]

  def index
    @posts = Post.order(created_at: :desc)
  end

  def new
    @post = Post.new(status: "draft")
  end

  def create
    @post = Post.new(post_params)
    @post.published_at = Time.current if @post.published?
    if @post.save
      redirect_to admin_posts_path, notice: "Blog post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @post.published_at ||= Time.current if post_params[:status] == "published"
    if @post.update(post_params)
      redirect_to admin_posts_path, notice: "Blog post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Blog post deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :summary, :content, :status, :cover_image, :category, :meta_title, :meta_description, :meta_keywords, :views_count)
  end
end
