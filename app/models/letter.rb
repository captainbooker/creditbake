class Letter < ApplicationRecord
  has_one_attached :experian_pdf
  has_one_attached :transunion_pdf
  has_one_attached :equifax_pdf
  has_one_attached :creditor_dispute

  belongs_to :user
  has_many :mailings

  COST = 24.99

  def total_pages
    return 0 unless creditor_dispute.attached?
    
    creditor_dispute.open do |file|
      reader = PDF::Reader.new(file.path)
      reader.page_count
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
  
    Tempfile.open do |file|
      file.binmode
      file.write(attachment.download)
      file.rewind
  
      reader = PDF::Reader.new(file.path)
      reader.page_count
    end
  end
end
