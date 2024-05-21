require 'nokogiri'

class HtmlParserService
  def initialize(document)
    @document = document
  end

  def extract_content
    file_path = download_document
    html = File.open(file_path) { |f| Nokogiri::HTML(f) }
    html
  end

  private

  def download_document
    file_path = Rails.root.join('tmp', @document.filename.to_s)
    File.open(file_path, 'wb') do |file|
      file.write(@document.download)
    end
    file_path
  end
end
