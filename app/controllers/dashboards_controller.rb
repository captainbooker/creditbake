class DashboardsController < ApplicationController
  include OpenaiPromptable
  before_action :authenticate_user!

  def disputing
    @inquiries = current_user.inquiries
    @accounts = current_user.accounts
  end

  def save_challenges
    Inquiry.where(id: params[:inquiry_ids], user_id: current_user.id).update_all(challenge: true) if params[:inquiry_ids].present?
    Account.where(id: params[:account_ids], user_id: current_user.id).update_all(challenge: true) if params[:account_ids].present?
    redirect_to letters_path, notice: 'Challenges saved successfully.'
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

    redirect_to disputing_path, notice: 'Attack created successfully and letters saved.'
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
    pdf = Prawn::Document.new do
      text "Letter for Round #{letter.name}", size: 20, style: :bold
      move_down 20
      text "Bureau: #{bureau_name}", size: 16, style: :bold
      text document_content
    end

    pdf_path = Rails.root.join("tmp/#{bureau_name}_letter_#{letter.id}.pdf")
    pdf.render_file(pdf_path)

    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{letter.id}.pdf", content_type: 'application/pdf')
  end
end
