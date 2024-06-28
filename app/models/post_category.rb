class PostCategory < ApplicationRecord
  belongs_to :post
  belongs_to :category

  # Ransack allowlisted attributes
  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "id", "post_id", "updated_at"]
  end
end
