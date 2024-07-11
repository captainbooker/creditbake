class CreditReport < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :user, optional: true
  has_one_attached :document
  has_many :disputes

  def extract_and_save_smart_credit_scores(json)
    parsed_json = JSON.parse(json)
    scores = parsed_json.dig("CreditReport", "Scores")
  
    if scores
      self.transunion_score = scores["Transunion"]&.to_i
      self.experian_score = scores["Experian"]&.to_i
      self.equifax_score = scores["Equifax"]&.to_i
    end
  end

  def extract_scores(json_content)
    parsed_json = JSON.parse(json_content)

    scores = extract_all_scores(parsed_json)
    self.experian_score = scores[:experian]
    self.transunion_score = scores[:transunion]
    self.equifax_score = scores[:equifax]
  end

  def extract_all_scores(json)
    scores = { experian: nil, transunion: nil, equifax: nil }
  
    json['BundleComponents']['BundleComponent'].each do |component|
      next unless component['CreditScoreType']
  
      case component.dig('Type', '$')
      when 'EXPReportV6', 'EXPVantageScoreV6'
        scores[:experian] = component['CreditScoreType']['@riskScore'].to_i
      when 'TUCReportV6', 'TUCVantageScoreV6'
        scores[:transunion] = component['CreditScoreType']['@riskScore'].to_i
      when 'EQFReportV6', 'EQFVantageScoreV6'
        scores[:equifax] = component['CreditScoreType']['@riskScore'].to_i
      end
    end
  
    scores
  end

  def calculate_score_changes
    last_report = CreditReport.where(user_id: self.user_id).order(created_at: :desc).second

    if last_report
      self.experian_score_change = self.experian_score - last_report.experian_score
      self.transunion_score_change = self.transunion_score - last_report.transunion_score
      self.equifax_score_change = self.equifax_score - last_report.equifax_score
    else
      self.experian_score_change = 0
      self.transunion_score_change = 0
      self.equifax_score_change = 0
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[client_id user_id username password security_question service experian_score transunion_score equifax_score experian_score_change transunion_score_change equifax_score_change created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
