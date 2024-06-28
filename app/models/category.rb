class Category < ApplicationRecord
  has_many :post_categories
  has_many :posts, through: :post_categories

  validates :name, presence: true, uniqueness: true

  # Ransack allowlisted attributes
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]
  end

  # Ransack allowlisted associations
  def self.ransackable_associations(auth_object = nil)
    ["posts", "post_categories"]
  end
end
