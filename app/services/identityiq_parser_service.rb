require 'json'

class IdentityiqParserService
  def initialize(content)
    @content = JSON.parse(content)
  end

  def extract_content
    {
      inquiries: extract_inquiries,
      accounts: extract_accounts
    }
  end

  private

  def extract_inquiries
    inquiries = []
    inquiry_partitions = @content.dig('BundleComponents', 'BundleComponent').select do |component|
      component.dig('TrueLinkCreditReportType', 'InquiryPartition')
    end
    
    inquiry_partitions.each do |component|
      inquiry_records = component.dig('TrueLinkCreditReportType', 'InquiryPartition')

      next unless inquiry_records

      inquiry_records.each do |inquiry_record|
        inquiry = inquiry_record['Inquiry']
        next unless inquiry

        inquiry_date = inquiry['@inquiryDate']
        inquiry_name = inquiry['@subscriberName']
        type_of_business = inquiry.dig('IndustryCode', '@description')
        address = inquiry.dig('Source', 'Bureau', '@description')
        bureau = inquiry.dig('Source', 'Bureau', '@abbreviation')

        inquiries << {
          inquiry_name: inquiry_name,
          type_of_business: type_of_business,
          inquiry_date: inquiry_date,
          address: address,
          credit_bureau: bureau
        }
      end
    end
    inquiries
  end

  def extract_accounts
    accounts = []
    account_partitions = @content.dig('BundleComponents', 'BundleComponent').select do |component|
      component.dig('TrueLinkCreditReportType', 'TradeLinePartition')
    end

    account_partitions.each do |component|
      tradeline_partitions = component.dig('TrueLinkCreditReportType', 'TradeLinePartition')
      next unless tradeline_partitions

      tradeline_partitions.each do |partition|
        tradelines = partition['Tradeline']
  
        next unless tradelines

        tradelines.each do |tradeline|
          next unless tradeline.is_a?(Hash) && tradeline['@accountNumber']
          
          account_number = tradeline['@accountNumber']
          account_status = tradeline.dig('AccountCondition', '@description')
          account_type = tradeline.dig('GrantedTrade', 'CreditType', '@description')
          account_name = tradeline['@creditorName']
          bureau = tradeline['@bureau']

          account = accounts.find { |acc| acc[:account_number] == account_number }

          if account.nil?
            account = { account_number: account_number, account_status: account_status, account_type: account_type, name: account_name, bureau_details: {} }
            accounts << account
          end

          account[:bureau_details][bureau.downcase.to_sym] = {
            credit_limit: tradeline.dig('GrantedTrade', 'CreditLimit', '$'),
            high_balance: tradeline['@highBalance'],
            high_credit: tradeline['@highBalance'],
            past_due_amount: tradeline.dig('GrantedTrade', '@amountPastDue'),
            payment_status: tradeline.dig('PayStatus', '@description'),
            date_opened: tradeline['@dateOpened'],
            date_of_last_payment: tradeline.dig('GrantedTrade', '@dateLastPayment')
          }
        end
      end
    end
    accounts
  end
end
