class CreditReport < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :user
  has_one_attached :document
  has_many :disputes


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
end
