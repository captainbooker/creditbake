class MailingsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!

  def create
    letter = Letter.find(params[:letter_id])
    color = params[:color] == 'true'

    attachments = {
      experian_pdf: letter.experian_pdf,
      transunion_pdf: letter.transunion_pdf,
      equifax_pdf: letter.equifax_pdf,
      creditor_dispute: letter.creditor_dispute,
      bankruptcy_pdf: letter.bankruptcy_pdf
    }.select { |name, attachment| attachment.attached? }

    total_cost = 0
    mailings = []


    attachments.each do |name, attachment|
      if attachment.attached?
        pages = count_pages(attachment)
        cost = calculate_mailing_cost(pages, color, 1)
        total_cost += cost
        mailings << { attachment: attachment, cost: cost, name: name }
      end
    end

    if current_user.credits >= total_cost
      mailings.each do |mailing|
        current_user.decrement!(:credits, mailing[:cost])
        @mailing_record = Mailing.create!(user: current_user, letter: letter, cost: mailing[:cost])
        Spending.create!(user: current_user, amount: mailing[:cost], description: "Mailing for #{mailing[:name]} / #{Date.today.strftime("%B %d, %Y")}")
      end

      SpendingMailer.mailing_cost_notification(current_user, mailings).deliver_now
      SpendingMailer.notify_admin_user(current_user, @mailing_record, mailings).deliver_now
      letter.update(mailed: true)

      redirect_to letters_path, notice: "Letters mailed successfully"
    else
      redirect_to maverick_payment_form_url, alert: "You don't have enough credits. Please add credits."
    end
  end

  def calculate_cost
    letter = Letter.find(params[:letter_id])
    color = params[:color] == 'true'

    attachments = {
      experian_pdf: letter.experian_pdf,
      transunion_pdf: letter.transunion_pdf,
      equifax_pdf: letter.equifax_pdf,
      creditor_dispute: letter.creditor_dispute,
      bankruptcy_pdf: letter.bankruptcy_pdf
    }.select { |name, attachment| attachment.attached? }

    total_cost_bw = 0
    total_cost_color = 0
    mailings = []


    attachments.each do |name, attachment|
      if attachment.attached?
        pages = count_pages(attachment)
        cost_bw = calculate_mailing_cost(pages, false, 1)
        cost_color = calculate_mailing_cost(pages, true, 1)
        total_cost_bw += cost_bw
        total_cost_color += cost_color
        mailings << { attachment: attachment, cost_bw: cost_bw, cost_color: cost_color, name: name }
      end
    end

    render json: { total_cost_bw: total_cost_bw, total_cost_color: total_cost_color, mailings: mailings }
  end

  private

  def calculate_mailing_cost(pages, color, number_of_letters)
    cost_per_page = color ? 0.10 : 0.05
    paper_cost = pages * 0.01
    envelope_cost = 0.10 * number_of_letters
    postage_cost = 0.63 * number_of_letters
    certified_mail_fee = 4.40 * number_of_letters
    return_receipt_fee = 2.20 * number_of_letters
    labor_cost = 1.25 * number_of_letters

    total_cost = (pages * cost_per_page) + paper_cost + envelope_cost + postage_cost + certified_mail_fee + return_receipt_fee + labor_cost
    markup = 0.10 * total_cost
    total_cost + markup
  end

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
