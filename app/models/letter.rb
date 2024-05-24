class Letter < ApplicationRecord
  has_one_attached :experian_pdf
  has_one_attached :transunion_pdf
  has_one_attached :equifax_pdf

  belongs_to :user
end
