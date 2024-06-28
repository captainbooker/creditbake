class BlogsController < ApplicationController
  before_action :set_post, only: [:show]

  # GET /posts
  def index
    if params[:category_id]
      @category = Category.find(params[:category_id])
      @posts = @category.posts
    else
      @posts = Post.all
    end
  end

  # GET /posts/:id
  def show
  end


  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end
end
