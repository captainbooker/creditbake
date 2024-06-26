module DownloadFiles
  extend ActiveSupport::Concern

  def download_all_files
    letter = Letter.find(params[:letter_id])
    files = [letter.experian_pdf, letter.transunion_pdf, letter.equifax_pdf, letter.bankruptcy_pdf].compact.select(&:attached?)

    if files.any?
      zip_data = Zip::OutputStream.write_buffer do |zip|
        files.each do |file|
          zip.put_next_entry(file.filename.to_s)
          zip.write(file.download)
        end
      end

      zip_data.rewind
      send_data zip_data.read, filename: "#{letter.name}_challenge_letter_#{Date.today}.zip", type: 'application/zip'
    else
      redirect_back fallback_location: letters_path, alert: 'No files to download'
    end
  end
end
