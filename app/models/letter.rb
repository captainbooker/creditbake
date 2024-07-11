class Letter < ApplicationRecord
  has_one_attached :experian_pdf
  has_one_attached :transunion_pdf
  has_one_attached :equifax_pdf
  has_one_attached :bankruptcy_pdf
  has_one_attached :creditor_dispute

  belongs_to :client, optional: true
  belongs_to :user, optional: true
  has_many :mailings

  COST = 18.99
  BANKRUPTCY_LETTERS = 5.99
  # Constants for Metro 2 Compliance Codes
  METRO_2_COMPLIANCE_CODES = {
    "HRCF12" => "creditor_name",
    "HRCF8" => "date_of_last_activity",
    "HRCF5-7" => "credit_bureau",
    "BSCF" => "base_segment_character_format",
    "J1S" => "j1_segment",
    "J2S" => "j2_segment",
    "K1S" => "k1_segment",
    "K2S" => "k2_segment",
    "K3S" => "k3_segment",
    "K4S" => "k4_segment",
    "L1S" => "l1_segment",
    "N1S" => "n1_segment",
    "TRCF" => "trailer_record_character_format",
    "HRPF" => "header_record_packed_format",
    "BSPF" => "base_segment_packed_format",
    "TRPF" => "trailer_record_packed_format",
    "D1" => "data_furnisher_1",
    "DF2" => "data_furnisher_2",
    "T" => "transunion",
    "F" => "equifax",
    "X" => "experian",
    "M" => "missing_but_required_reported",
    "E" => "potential_error",
    "I" => "inconsistent",
    "N" => "not_available_or_deceptive",
    "Q" => "questionable_conditioned",
    "D" => "deviant_from_standards",
    "U" => "unconfirmed_or_uncertified_compliant",
    "CRRG" => "credit_reporting_resource_guide",
    "FCRA" => "fair_credit_reporting_act",
    "BSCF7" => "account_number",
    "BSCF12" => "high_balance",
    "BSCF24" => "last_verified",
    "BSCF10" => "date_opened",
    "BSCF21" => "balance_owed",
    "BSCF26" => "closed_date",
    "BSCF17A" => "account_rating",
    "BSCF37" => "account_description",
    "J1SF10" => "j1_segment_f10",
    "J2SF10" => "j2_segment_f10",
    "BSCF20" => "dispute_status",
    "BSCF17B" => "payment_status",
    "BSCF19" => "creditor_remarks",
    "BSCF15" => "payment_amount",
    "BSCF27" => "last_payment",
    "BSCF13" => "term_length",
    "BSCF22" => "past_due_amount",
    "BSCF9" => "account_type",
    "BSCF14" => "payment_frequency",
    "BSCF11" => "credit_limit",
    "BSCF18" => "two_year_payment_history",
    "BSCF30-31" => "personal_information_name",
    "BSCF40,42-44" => "person_information_current_adress",
    "BSCF35" => "personal_information_date_of_birth"
  }.freeze
  
  def total_pages
    return 0 unless creditor_dispute.attached?
    
    creditor_dispute.open do |file|
      reader = PDF::Reader.new(file.path)
      reader.page_count
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name bureau experian_document transunion_document equifax_document bankruptcy_document user_id mailed tracking_number experian_tracking_number transunion_tracking_number equifax_tracking_number created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def attached_documents_count
    [
      experian_pdf,
      transunion_pdf,
      equifax_pdf,
      bankruptcy_pdf,
      creditor_dispute
    ].count(&:attached?)
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
