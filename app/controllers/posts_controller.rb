class PostsController < ApplicationController
  def index
    @posts = Post.published
    @posts = @posts.where(category: params[:category]) if params[:category].present?
    @posts = @posts.page(params[:page]).per(20)
  end

  def show
    @post = Post.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path
  end
end
