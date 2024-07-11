require 'json'

class IdentityiqParserService
  def initialize(content)
    @content = JSON.parse(content)
  end

  def extract_content
    {
      inquiries: extract_inquiries,
      accounts: extract_accounts,
      personal_information: extract_personal_information
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

          remarks = tradeline['Remark']
          comments = remarks.is_a?(Array) ? remarks.map { |remark| remark.dig('RemarkCode', '@description') }.join(', ') : nil

          account[:bureau_details][bureau.downcase.to_sym] = {
            credit_limit: tradeline.dig('GrantedTrade', 'CreditLimit', '$'),
            high_balance: tradeline['@highBalance'],
            high_credit: tradeline['@highBalance'],
            past_due_amount: tradeline.dig('GrantedTrade', '@amountPastDue'),
            payment_status: tradeline.dig('PayStatus', '@description'),
            date_opened: tradeline['@dateOpened'],
            date_of_last_payment: tradeline.dig('GrantedTrade', '@dateLastPayment'),
            comment: comments,
            monthly_payment: tradeline.dig('GrantedTrade', '@monthlyPayment')
          }
        end
      end
    end
    accounts
  end

  def extract_personal_information
    personal_info_component = @content.dig('BundleComponents', 'BundleComponent').find do |component|
      component.dig('TrueLinkCreditReportType', 'Borrower')
    end

    return {} unless personal_info_component

    borrower = personal_info_component.dig('TrueLinkCreditReportType', 'Borrower')
    {
      name: extract_borrower_names(borrower['BorrowerName']),
      date_of_birth: extract_borrower_births(borrower['Birth']),
      current_addresses: extract_addresses(borrower['BorrowerAddress']),
      previous_addresses: extract_addresses(borrower['PreviousAddress']),
      employers: extract_employers(borrower['Employer'])
    }
  end

  def extract_borrower_names(names)
    names.map do |name|
      {
        first: name.dig('Name', '@first'),
        middle: name.dig('Name', '@middle'),
        last: name.dig('Name', '@last'),
        type: name.dig('NameType', '@description'),
        bureau: name.dig('Source', 'Bureau', '@description')
      }
    end
  end

  def extract_borrower_births(births)
    births.map do |birth|
      {
        date: birth.dig('BirthDate', '@year'),
        month: birth.dig('BirthDate', '@month'),
        day: birth.dig('BirthDate', '@day'),
        bureau: birth.dig('Source', 'Bureau', '@description')
      }
    end
  end

  def extract_addresses(addresses)
    addresses.map do |address|
      {
        street: address.dig('CreditAddress', '@unparsedStreet') || "#{address.dig('CreditAddress', '@houseNumber')} #{address.dig('CreditAddress', '@streetName')} #{address.dig('CreditAddress', '@streetType')}",
        city: address.dig('CreditAddress', '@city'),
        state: address.dig('CreditAddress', '@stateCode'),
        postal_code: address.dig('CreditAddress', '@postalCode'),
        bureau: address.dig('Source', 'Bureau', '@description')
      }
    end
  end

  def extract_employers(employers)
    employers.map do |employer|
      {
        name: employer['@name'],
        date_reported: employer['@dateReported'],
        date_updated: employer['@dateUpdated'],
        bureau: employer.dig('Source', 'Bureau', '@description')
      }
    end
  end
end
