require "watir"

module DataScrapers
  REPORTS_TABLE_BODY_X_PATH = "/html/body/div[1]/div/div/div[1]/div/div[2]/div/div/div[8]/div/div/div/div/div[1]/table/tbody"
  class EarningsReportScraper
    def scrape
      prefs = {
        download: {
          prompt_for_download: false,
          default_directory: '/home/fraser/Downloads'
        }
      }
      @driver = Watir::Browser.new(:chrome, headless: false, options: {prefs: prefs})

      Symbols::US_STOCKS.each_with_index do |symbol, index|
      # ["VZ"].each_with_index do |symbol, index|
        continue_processing = true
        puts "Processing #{symbol}"
        @driver.goto(url(sym: symbol))

        if index == 0
          sleep(1)
          accept_terms_btn = @driver.element(xpath: "/html/body/div/div/div/div/form/div[2]/div[2]/button")
          accept_terms_btn.click
          sleep(2)
        end


        tbody= @driver.element(xpath: REPORTS_TABLE_BODY_X_PATH)
        trs = tbody.trs

        trs.each do |row|

          unless continue_processing
            continue_processing = true
            break
          end

          estimated_eps = row[3].text
          reported_eps = row[4].text
          surprise_text = row[5].text

          next if estimated_eps == "-" || reported_eps == "-" || surprise_text == "-"

          date_string = row[2].text[..-4]
          date_time = DateTime.parse(date_string) + 4.hours

          if EarningReport.exists?(symbol: symbol, date_time: date_time)
            p "earning report already exists...moving onto next symbol"
            continue_processing = false
            next
          end

          p " ** creating new report"
          EarningReport.create!(
            symbol: symbol,
            date_time: date_time,
            estimated_eps: estimated_eps,
            reported_eps: reported_eps,
            surprise: surprise_text.to_f
          )
        end

      end
      @driver.close
    end

    private

    def url(sym:)
      "https://finance.yahoo.com/calendar/earnings?symbol=#{sym}"
    end
  end
end