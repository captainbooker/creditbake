class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories

  has_one_attached :header_image

  validates :title, presence: true
  validates :body, presence: true
  validates :user, presence: true

  def should_generate_new_friendly_id?
    title_changed?
  end

  # Ransack allowlisted attributes
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "slug", "title", "updated_at", "user_id"]
  end

  # Ransack allowlisted associations
  def self.ransackable_associations(auth_object = nil)
    ["user", "categories", "post_categories"]
  end
end
