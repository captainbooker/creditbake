class UploadsController < ApplicationController
  before_action :authenticate_admin_user!

  def create
    blob = ActiveStorage::Blob.create_and_upload!(io: params[:file], filename: params[:file].original_filename)
    render json: { link: url_for(blob) }, content_type: 'text/html'
  end
end
