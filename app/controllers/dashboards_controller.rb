class DashboardsController < ApplicationController
  include OpenaiPromptable
  before_action :authenticate_user!

  def index
  end

  def disputing
    @inquiries = current_user.inquiries
    @accounts = current_user.accounts.includes(:bureau_details)
  end  

  def save_challenges
    Inquiry.where(id: params[:inquiry_ids], user_id: current_user.id).update_all(challenge: true) if params[:inquiry_ids].present?
    Account.where(id: params[:account_ids], user_id: current_user.id).update_all(challenge: true) if params[:account_ids].present?
    redirect_to letters_path, notice: 'Challenged items saved successfully.'
  end

  def letters
    @letters = current_user.letters
  end

  def create_attack
    round = params[:round].to_i

    inquiries = current_user.inquiries.where(challenge: true)
    accounts = current_user.accounts.where(challenge: true)

    inquiry_details = inquiries.map { |inquiry| { name: inquiry.inquiry_name, bureau: inquiry.credit_bureau } }
    account_details = accounts.map { |account| { number: account.account_number, bureau: account.bureau_details.pluck(:bureau) } }

    responses = send_prompts_for_round(round, inquiry_details, account_details)

    letter = Letter.create!(
      name: "Round #{round}",
      experian_document: responses[:experian],
      transunion_document: responses[:transunion],
      equifax_document: responses[:equifax],
      user: current_user
    )

    generate_pdfs(letter)

    redirect_to letters_path, notice: 'Attack created successfully and letters saved.'
  end

  private

  def generate_pdfs(letter)
    generate_pdf(letter, 'experian_document', :experian_pdf)
    generate_pdf(letter, 'transunion_document', :transunion_pdf)
    generate_pdf(letter, 'equifax_document', :equifax_pdf)
  end

  def generate_pdf(letter, document_field, pdf_attachment)
    document_content = letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize
    user = current_user
    pdf = Prawn::Document.new do
      text document_content
      if user.id_document.attached?
        text "ID Document:"
        id_document_path = Rails.root.join("tmp/#{user.id_document.filename}")
        File.open(id_document_path, 'wb') do |file|
          file.write(user.id_document.download)
        end
        image id_document_path, width: 500, height: 300
      end
      
      # Add Utility Bill if attached
      if user.utility_bill.attached?
        text "Utility Bill:"
        utility_bill_path = Rails.root.join("tmp/#{user.utility_bill.filename}")
        File.open(utility_bill_path, 'wb') do |file|
          file.write(user.utility_bill.download)
        end
        image utility_bill_path, width: 500, height: 300
      end
    end

    pdf_path = Rails.root.join("tmp/#{bureau_name}_letter_#{letter.id}.pdf")
    pdf.render_file(pdf_path)

    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{letter.id}.pdf", content_type: 'application/pdf')
  end
end
