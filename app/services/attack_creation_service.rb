class AttackCreationService
  def initialize(user, round, controller)
    @user = user
    @round = round
    @controller = controller
  end

  def call
    return unless sufficient_credits?

    inquiries = @user.inquiries.where(challenge: true)
    accounts = @user.accounts.where(challenge: true).includes(:bureau_details)

    inquiry_details = format_inquiries(inquiries)
    account_details = format_accounts(accounts)

    responses = @controller.send_prompts_for_round(@round, inquiry_details, account_details)

    letter = create_letter(responses)

    generate_pdfs(letter)
    decrement_credits
    log_spending(letter)
  end

  private

  def sufficient_credits?
    @user.credits >= Letter::COST
  end

  def format_inquiries(inquiries)
    inquiries.map { |inquiry| { name: inquiry.inquiry_name, bureau: inquiry.credit_bureau } }
  end

  def format_accounts(accounts)
    accounts.map do |account|
      {
        name: account.name,
        number: account.account_number,
        reason: account.reason,
        bureau_details: account.bureau_details.map do |detail|
          {
            bureau: detail.bureau,
            balance_owed: detail.balance_owed,
            high_credit: detail.high_credit,
            credit_limit: detail.credit_limit,
            past_due_amount: detail.past_due_amount,
            payment_status: detail.payment_status,
            date_opened: detail.date_opened,
            date_of_last_payment: detail.date_of_last_payment,
            last_reported: detail.last_reported
          }
        end
      }
    end
  end

  def create_letter(responses)
    Letter.create!(
      name: "Round #{@round}",
      experian_document: responses[:experian],
      transunion_document: responses[:transunion],
      equifax_document: responses[:equifax],
      user: @user
    )
  end

  def generate_pdfs(letter)
    PdfGenerationService.new(@user, letter).call
  end

  def decrement_credits
    @user.decrement!(:credits, Letter::COST)
  end

  def log_spending(letter)
    Spending.create!(user: @user, amount: Letter::COST, description: "Letter Generated: #{letter.id}")
  end
end
