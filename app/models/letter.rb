class Letter < ApplicationRecord
  has_one_attached :experian_pdf
  has_one_attached :transunion_pdf
  has_one_attached :equifax_pdf
  has_one_attached :creditor_dispute

  belongs_to :user
  has_many :mailings

  def total_pages
    if creditor_dispute.attached?
      count_pages(creditor_dispute)
    else
      count_pages(experian_pdf) + count_pages(transunion_pdf) + count_pages(equifax_pdf)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name bureau experian_document transunion_document equifax_document user_id mailed tracking_number experian_tracking_number transunion_tracking_number equifax_tracking_number created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def count_pages(attachment)
    return 0 unless attachment.attached?
    pdf_path = ActiveStorage::Blob.service.send(:path_for, attachment.key)
    reader = PDF::Reader.new(pdf_path)
    reader.page_count
  end
end
