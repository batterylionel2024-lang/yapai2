class PostsController < ApplicationController
  def index
    @posts = Post.published
    @posts = @posts.where(category: params[:category]) if params[:category].present?
    
    @total_articles = @posts.count
    # 统计当前分类下所有文章的 views_count 总和
    @total_reads = @posts.sum(:views_count)
    
    @posts = @posts.page(params[:page]).per(20)
  end

  def show
    @post = Post.published.find(params[:id])
    @post.increment_views!
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path
  end
end
