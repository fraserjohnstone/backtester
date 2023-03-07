require "watir"

module DataScrapers
  module TickScrapers
    class BaseTickDataScraper
      SYMBOL_X_PATHS = {}
      MONTH_BUTTON_X_PATHS = {
        "January" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[1]",
        "February" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[2]",
        "March" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[3]",
        "April" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[4]",
        "May" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[5]",
        "June" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[6]",
        "July" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[7]",
        "August" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[8]",
        "September" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[9]",
        "October" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[10]",
        "November" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[11]",
        "December" => "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[12]"
      }
      DATES_TO_SKIP = []

      START_DATE = DateTime.parse("2012-01-01")
      END_DATE = DateTime.parse("2022-12-31")
      TARGET_BTN_XPATH = ""

      attr_reader :iframe, :driver

      def scrape
        prefs = {
          download: {
            prompt_for_download: false,
            default_directory: '/home/fraser/Downloads'
          }
        }
        @driver = Watir::Browser.new(:chrome, headless: false, options: {prefs: prefs})

        @driver.goto("https://www.dukascopy.com/plugins/fxMarketWatch/?historical_data")

        sleep(3)

        @iframe = driver.iframe(xpath: "/html/body/div[1]/div[2]/div[1]/div[2]/div[11]/div/iframe")
        i = 0

        syms = self.class::SYMBOL_X_PATHS.keys

        syms.each do |symbol|
          next unless self.class::SYMBOL_X_PATHS.key?(symbol)
          Dir.mkdir(Rails.root.join("tick_data", symbol)) unless Dir.exist?(Rails.root.join("tick_data", symbol))

          date = self.class::START_DATE

          while date < self.class::END_DATE
            p "Processing date: #{date.strftime("%D")} for #{symbol}"

            if data_exists_or_sat?(date, symbol) || self.class::DATES_TO_SKIP.include?(date)
              p " - Skipping"
              date += 1.day
              next
            end

            target_btn = iframe.element(xpath: self.class::TARGET_BTN_XPATH)
            target_btn.click

            gather_day_data_for_symbol(symbol, date, i)

            date_btn = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[3]/div")
            date = DateTime.parse(date_btn.text)

            Dir.glob("/home/fraser/Downloads/*#{symbol}*_Ticks_*.csv") do |download|
              unless File.zero?(download)
                fn = download.split("/").last
                sym = fn.split("_").first
                sym = sym.split(".").first if sym.include?(".")

                date_str = fn.split("-").last.delete(".csv").gsub(".", "-")

                File.open(Rails.root.join("tick_data", sym, "#{date_str}.csv"), "w") do |f|
                  f.write(File.read(download))
                end
              end

              File.delete(download)
            end

            date += 1.day
            i += 1
          end
        end

        driver.close
      end

      def data_exists_or_sat?(date, symbol)
        file_name = Rails.root.join("tick_data", symbol, "#{date.strftime("%d%m%Y")}.csv")

        File.exists?(file_name) || date.strftime("%A") == "Saturday" || date.strftime("%A") == "Sunday"
      end

      def gather_day_data_for_symbol(symbol, date, i)
        instrument_btn = iframe.element(xpath: self.class::SYMBOL_X_PATHS[symbol])
        instrument_btn.click

        date_btn = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[3]/div")
        date_btn.click

        today_button = iframe.element(xpath: "/html/body/div[10]/table/tfoot/tr/td[1]/button")
        today_button.click

        date_btn.click

        month_name_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[1]/button[2]")
        month_name_button.click

        month_button =  iframe.element(xpath: MONTH_BUTTON_X_PATHS[date.strftime("%B")])
        month_button.click

        year_name_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[2]/button[2]")
        year_name_button.click

        previous_year_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[2]/button[1]")

        until year_name_button.text == date.year.to_s
          previous_year_button.click
        end

        days_grid = iframe.element(xpath: "/html/body/div[10]/table/tbody")

        day_buttons = days_grid.elements(class: "d-Ch-fi-Ch").to_a
        day_buttons.shift until day_buttons.first.text == "1"
        day_buttons.pop until day_buttons.last.text == date.end_of_month.day.to_s

        day_button = day_buttons.find { |btn| btn.text == date.day.to_s }
        day_button.click

        download_button = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[9]/div")
        download_button.click

        if i == 0
          agree_to_cfd_stock_terms(iframe)

          sleep(1)
          iframe.element(xpath: "/html/body/div[9]/div[5]/div/div/div[2]/div[3]/div[1]/div/div[4]/div[1]/div/div/input").send_keys("fjohnstone@usertesting.com")
          iframe.element(xpath: "/html/body/div[9]/div[5]/div/div/div[2]/div[3]/div[1]/div/div[4]/div[2]/div/div/input").send_keys("R@unchywasp1")
          submit_button = iframe.element(xpath: "/html/body/div[9]/div[5]/div/div/div[2]/div[3]/div[1]/div/div[4]/div[4]/div[1]/div")

          sleep(1)

          submit_button.click
        end

        retry_until = Time.now + 60.seconds

        begin
          save_csv_button = iframe.element(xpath: "/html/body/div[9]/div[1]/div[5]/div/div[2]/div[1]")
          save_csv_button.click


          reload_button = iframe.element(xpath: "/html/body/div[9]/div[1]/div[5]/div/div[3]")
          reload_button.click
        rescue
          sleep(1)
          retry if Time.now < retry_until
        end
      end

      def agree_to_cfd_stock_terms(iframe)

      end
    end
  end
end