class BlogsController < ApplicationController
  before_action :redirect_if_signed_in
  before_action :set_post, only: [:show]

  # GET /posts
  def index
    if params[:category_id]
      @category = Category.find(params[:category_id])
      @posts = @category.posts
    else
      @posts = Post.all.page(params[:page]).per(12) 
    end
  end

  # GET /posts/:id
  def show
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def redirect_if_signed_in
    redirect_to unauthenticated_root_path if user_signed_in?
  end
end
