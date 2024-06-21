class PdfGenerationService
  def initialize(user, letter)
    @user = user
    @letter = letter
  end

  def call
    generate_pdf('experian_document', :experian_pdf)
    generate_pdf('transunion_document', :transunion_pdf)
    generate_pdf('equifax_document', :equifax_pdf)
  end

  private

  def generate_pdf(document_field, pdf_attachment)
    document_content = @letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize

    pdf_path = Rails.root.join("tmp/#{bureau_name}_letter_#{@letter.id}.pdf")

    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.text document_content

      add_attachments_to_pdf(pdf)
    end

    @letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{@letter.id}.pdf", content_type: 'application/pdf')
  end

  def add_attachments_to_pdf(pdf)
    add_image_to_pdf(@user.signature, pdf, "Signature:", 100, 100) if @user.signature.attached?
    add_image_to_pdf(@user.id_document, pdf, "ID Document:", 500, 400) if @user.id_document.attached?
    add_utility_bill_to_pdf(pdf) if @user.utility_bill.attached?
  end

  def add_utility_bill_to_pdf(pdf)
    utility_bill_path = save_attachment_to_temp(@user.utility_bill)
    case file_mime_type(utility_bill_path)
    when 'application/pdf'
      image_path = convert_pdf_to_image(utility_bill_path)
      add_image_to_pdf(image_path, pdf, "Utility Bill:", 500, 400)
    when 'image/jpeg', 'image/png'
      add_image_to_pdf(utility_bill_path, pdf, "Utility Bill:", 400, 300)
    else
      Rails.logger.error "Unsupported file type: #{file_mime_type(utility_bill_path)}"
    end
  end

  def add_image_to_pdf(image_path, pdf, title, width, height)
    pdf.start_new_page
    pdf.text title
    pdf.image image_path, width: width, height: height, position: :center
  end


  def save_attachment_to_temp(attachment)
    attachment_path = Rails.root.join("tmp/#{attachment.filename}")
    File.open(attachment_path, 'wb') do |file|
      file.write(attachment.download)
    end
    attachment_path
  end

  def convert_pdf_to_image(pdf_path)
    image_path = pdf_path.sub('.pdf', '.png')
    MiniMagick::Tool::Convert.new do |convert|
      convert.density(300)
      convert.quality(200)
      convert << pdf_path << image_path
    end
    image_path
  end

  def file_mime_type(path)
    `file --brief --mime-type #{path}`.strip
  end
end
