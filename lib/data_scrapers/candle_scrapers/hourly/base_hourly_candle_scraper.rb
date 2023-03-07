require "watir"

module DataScrapers
  module CandleScrapers
    module Hourly
      class BaseHourlyCandleScraper
        BASE_BTN = "/html/body/div[9]/div[2]/div/div/div/div[1]/div[2]"
        BASE_HOUR_BTN = "/html/body/div[12]/div[4]"

        UNIT_FOR_TIMEFRAMES = {
          "h1" => "/html/body/div[13]/div[1]",
          "h2" => "/html/body/div[13]/div[2]",
          "h4" => "/html/body/div[13]/div[4]"
        }
        UNIT_BTN = "/html/body/div[9]/div[2]/div/div/div/div[1]/div[1]"

        attr_reader :iframe, :driver

        def scrape
          prefs = {
            download: {
              prompt_for_download: false,
              default_directory: '/home/fraser/Downloads'
            }
          }
          # @driver = Watir::Browser.new(:chrome, headless: true, options: {prefs: prefs})
          @driver = Watir::Browser.new(:chrome)

          @driver.goto("https://www.dukascopy.com/plugins/fxMarketWatch/?historical_data")

          sleep(3)

          @iframe = driver.iframe(xpath: "/html/body/div[1]/div[2]/div[1]/div[2]/div[11]/div/iframe")
          i = 0

          self.class::SYMBOL_X_PATHS.keys.each do |symbol|
            Dir.mkdir(Rails.root.join("candle_data", symbol)) unless Dir.exist?(Rails.root.join("candle_data", symbol))
            Dir.mkdir(Rails.root.join("candle_data", symbol, "h1")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "h1"))
            Dir.mkdir(Rails.root.join("candle_data", symbol, "h2")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "h2"))
            Dir.mkdir(Rails.root.join("candle_data", symbol, "h4")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "h4"))

            ["h1", "h2", "h4"].each do |timeframe|
              p "Processing candles: #{timeframe} for #{symbol}"

              if data_exists?(timeframe, symbol)
                p " - Skipping"
                next
              end

              target_btn = iframe.element(xpath: self.class::TARGET_BTN_XPATH)
              target_btn.click

              gather_candle_data_for_symbol(symbol, timeframe, i)

              Dir.glob("/home/fraser/Downloads/*_Candlestick_*_Hour_*.csv") do |download|
                unless File.zero?(download)
                  fn = download.split("/").last
                  parts = fn.split("_")
                  sym = parts.first
                  sym = sym.split(".").first if sym.include?(".")
                  tf = "h#{parts.third}"

                  File.open(Rails.root.join("candle_data", sym, tf, "#{tf}.csv"), "w") do |f|
                    f.write(File.read(download))
                  end
                end

                File.delete(download)
              end

              i += 1
            end
          end

          driver.close
        end

        def data_exists?(timeframe, symbol)
          file_name = Rails.root.join("candle_data", symbol, timeframe, "#{timeframe}.csv")

          File.exists?(file_name)
        end

        def gather_candle_data_for_symbol(symbol, timeframe, i)
          instrument_btn = iframe.element(xpath: self.class::SYMBOL_X_PATHS[symbol])
          instrument_btn.click

          # switch to hourly

          base_btn = iframe.element(xpath: self.class::BASE_BTN)
          base_btn.click

          base_hour_btn = iframe.element(xpath: self.class::BASE_HOUR_BTN)
          base_hour_btn.click

          # switch to the correct timeframe
          unit_btn = iframe.element(xpath: UNIT_BTN)
          unit_btn.click

          unit_btn = iframe.element(xpath: UNIT_FOR_TIMEFRAMES[timeframe])
          unit_btn.click

          # from date

          from_date_btn = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[3]/div")
          from_date_btn.click

          today_button = iframe.element(xpath: "/html/body/div[10]/table/tfoot/tr/td[1]/button")
          today_button.click

          from_date_btn.click

          month_name_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[1]/button[2]")
          month_name_button.click

          jan_button =  iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[1]/div/ul/li[1]")
          jan_button.click

          year_name_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[2]/button[2]")
          year_name_button.click

          previous_year_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[2]/button[1]")

          until year_name_button.text == "2011"
            previous_year_button.click
          end

          days_grid = iframe.element(xpath: "/html/body/div[10]/table/tbody")

          day_buttons = days_grid.elements(class: "d-Ch-fi-Ch").to_a
          day_buttons.shift until day_buttons.first.text == "1"

          day_button = day_buttons.first
          day_button.click

          # to date

          to_date_btn = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[4]/div")
          to_date_btn.click

          today_button = iframe.element(xpath: "/html/body/div[11]/table/tfoot/tr/td[1]/button")
          today_button.click

          to_date_btn.click

          month_name_button = iframe.element(xpath: "/html/body/div[11]/table/thead/tr/td[1]/button[2]")
          month_name_button.click

          jan_button =  iframe.element(xpath: "/html/body/div[11]/table/thead/tr/td[1]/div/ul/li[1]")
          jan_button.click

          days_grid = iframe.element(xpath: "/html/body/div[11]/table/tbody")

          day_buttons = days_grid.elements(class: "d-Ch-fi-Ch").to_a
          day_buttons.shift until day_buttons.first.text == "1"

          day_button = day_buttons.first
          day_button.click

          filter_btn = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[5]/div")
          filter_btn.click

          filter_all_btn = iframe.element(xpath: "/html/body/div[14]/div[1]")
          filter_all_btn.click

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

          retry_until = Time.now + 120.seconds

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
      end

      def agree_to_cfd_stock_terms(iframe)

      end
    end
  end
end