module ParseCreditReports
  extend ActiveSupport::Concern

  private

  def parse_credit_report(credit_report)
    document_content = credit_report.document.download

    parser = case credit_report.service
             when 'identityiq'
               IdentityiqParserService.new(document_content)
             when 'creditdyno'
               CreditDynoParserService.new(document_content)
             else
               raise 'Unknown credit report service'
             end

    content = parser.extract_content
    process_parsed_content(content, credit_report)
  end

  def process_parsed_content(content, credit_report)
    inquiries = content[:inquiries]
    accounts = content[:accounts]

    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("DELETE FROM inquiries WHERE user_id = #{current_user.id}")
      BureauDetail.where(account_id: current_user.accounts.pluck(:id)).delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM accounts WHERE user_id = #{current_user.id}")
    end

    inquiries.each do |inquiry_attrs|
      inquiry_attrs[:user] = current_user
      Inquiry.create!(inquiry_attrs)
    end

    accounts.each do |account_attrs|
      next if account_attrs[:account_number].nil?

      account = Account.find_or_create_by!(
        account_number: account_attrs[:account_number],
        user_id: current_user.id
      ) do |acc|
        acc.account_type = account_attrs[:account_type]
        acc.account_status = account_attrs[:account_status]
        acc.name = account_attrs[:name]
      end

      account_attrs[:bureau_details].each do |bureau, details|
        next unless [:transunion, :experian, :equifax].include?(bureau)

        BureauDetail.create!(
          account: account,
          bureau: bureau,
          balance_owed: details[:high_balance],
          high_credit: details[:high_credit],
          credit_limit: details[:credit_limit],
          past_due_amount: details[:past_due_amount],
          payment_status: details[:payment_status],
          date_opened: details[:date_opened],
          date_of_last_payment: details[:date_of_last_payment]
        )
      end
    end
  end
end
