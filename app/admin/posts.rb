ActiveAdmin.register Post do
  permit_params :title, :user_id, :header_image, :body, category_ids: [], images: []

  member_action :upload, method: [:post] do
    success = resource.images.attach(params[:file_upload])
    result = success ? { link: url_for(resource.images.last) } : {}
    render json: result
  end

  form do |f|
    f.inputs 'Post Details' do
      f.input :user, as: :select, collection: User.all.collect { |user| [user.email, user.id] }
      f.input :title
      f.input :header_image, as: :file
      f.input :body, as: :froala_editor, input_html: { data: { options: { imageUploadParam: 'file_upload', imageUploadURL: upload_admin_post_path(resource.id), toolbarButtons: %w[bold italic underline | insertImage insertVideo insertFile] } } }
      f.input :categories, as: :check_boxes, collection: Category.all
    end
    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def create
      @post = Post.new(permitted_params[:post])
      @post.user = User.find(params[:post][:user_id]) # Ensure the post is associated with the selected user
      if @post.save
        redirect_to admin_post_path(@post), notice: "Post was successfully created."
      else
        render :new
      end
    end

    def update
      @post = Post.friendly.find(params[:id])
      if @post.update(permitted_params[:post])
        redirect_to admin_post_path(@post), notice: "Post was successfully updated."
      else
        render :edit
      end
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :user
    column :created_at
    actions
  end

  filter :title
  filter :user
  filter :categories, as: :select, collection: -> { Category.all }
  filter :created_at

  show do
    attributes_table do
      row :title
      row :body do |post|
        post.body.to_s.html_safe
      end
      row :user
      row :created_at
      row :updated_at
      row :header_image do |post|
        if post.header_image.attached?
          image_tag url_for(post.header_image), style: 'max-width: 100%; height: auto;'
        else
          "No image"
        end
      end
    end
    panel "Categories" do
      table_for post.categories do
        column :name
      end
    end
    active_admin_comments
  end
end
