require "watir"

module DataScrapers
  module CandleScrapers
    module Minute
      class BaseMinuteCandleScraper
        BASE_BTN = "/html/body/div[9]/div[2]/div/div/div/div[1]/div[2]"
        BASE_MINUTE_BTN = "/html/body/div[12]/div[3]"

        UNIT_BTN = "/html/body/div[9]/div[2]/div/div/div/div[1]/div[1]"
        UNIT_FOR_TIMEFRAMES = {
          # "m1" => "/html/body/div[13]/div[1]",
          "m5" => "/html/body/div[13]/div[5]",
          "m15" => "/html/body/div[13]/div[11]",
          "m30" => "/html/body/div[13]/div[16]",
        }

        attr_reader :iframe, :driver

        def scrape
          @driver = Watir::Browser.new(:chrome)

          i = 0

          syms = self.class::SYMBOL_X_PATHS.keys

          syms.each do |symbol|
            Dir.mkdir(Rails.root.join("candle_data", symbol)) unless Dir.exist?(Rails.root.join("candle_data", symbol))
            Dir.mkdir(Rails.root.join("candle_data", symbol, "m30")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "m30"))
            Dir.mkdir(Rails.root.join("candle_data", symbol, "m15")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "m15"))
            Dir.mkdir(Rails.root.join("candle_data", symbol, "m5")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "m5"))
            # Dir.mkdir(Rails.root.join("candle_data", symbol, "m1")) unless Dir.exist?(Rails.root.join("candle_data", symbol, "m1"))

            ["m5", "m15", "m30"].each do |timeframe|
              (2017..2022).step(2).each do |start_year|
                p "Processing candles (#{start_year}): #{timeframe} for #{symbol}"

                end_year = start_year + 1

                if data_exists?(timeframe, symbol, start_year)
                  p " - Skipping because data exists"
                  next
                end

                @driver.goto("https://www.dukascopy.com/plugins/fxMarketWatch/?historical_data")
                sleep(2)
                @iframe = driver.iframe(xpath: "/html/body/div[1]/div[2]/div[1]/div[2]/div[11]/div/iframe")

                target_btn = iframe.element(xpath: self.class::TARGET_BTN_XPATH)
                target_btn.click

                gather_candle_data_for_symbol(symbol, timeframe, i, start_year, end_year)

                Dir.glob("/home/fraser/Downloads/*_Candlestick_*_M_*.csv") do |download|
                  unless File.zero?(download)
                    fn = download.split("/").last
                    parts = fn.split("_")
                    sym = parts.first
                    sym = sym.split(".").first if sym.include?(".")
                    tf = "m#{parts.third}"
                    year = parts[5].split(".").third.split("-").first


                    File.open(Rails.root.join("candle_data", sym, tf, "#{tf}-#{year}.csv"), "w") do |f|
                      f.write(File.read(download))
                    end
                  end

                  File.delete(download)
                end
                i += 1
              end
            end
          end

          driver.close
        end

        def data_exists?(timeframe, symbol, start_year)
          file_name = Rails.root.join("candle_data", symbol, timeframe, "#{timeframe}-#{start_year}.csv")

          File.exists?(file_name)
        end

        def gather_candle_data_for_symbol(symbol, timeframe, i, start_year, end_year)
          instrument_btn = iframe.element(xpath: self.class::SYMBOL_X_PATHS[symbol])
          instrument_btn.click

          # switch to minute

          base_btn = iframe.element(xpath: BASE_BTN)
          base_btn.click

          base_minute_btn = iframe.element(xpath: BASE_MINUTE_BTN)
          base_minute_btn.click

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
          next_year_button = iframe.element(xpath: "/html/body/div[10]/table/thead/tr/td[2]/button[3]")

          if start_year < year_name_button.text.to_i
            until year_name_button.text == "#{start_year}"
              previous_year_button.click
            end
          elsif start_year > year_name_button.text.to_i
            until year_name_button.text == "#{start_year}"
              next_year_button.click
            end
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

          dec_button =  iframe.element(xpath: "/html/body/div[11]/table/thead/tr/td[1]/div/ul/li[12]")
          dec_button.click

          year_name_button = iframe.element(xpath: "/html/body/div[11]/table/thead/tr/td[2]/button[2]")
          year_name_button.click

          previous_year_button = iframe.element(xpath: "/html/body/div[11]/table/thead/tr/td[2]/button[1]")
          next_year_button = iframe.element(xpath: "/html/body/div[11]/table/thead/tr/td[2]/button[3]")

          if end_year < year_name_button.text.to_i
            until year_name_button.text == "#{end_year}"
              previous_year_button.click
            end
          elsif end_year > year_name_button.text.to_i
            until year_name_button.text == "#{end_year}"
              next_year_button.click
            end
          end

          days_grid = iframe.element(xpath: "/html/body/div[11]/table/tbody")

          day_buttons = days_grid.elements(class: "d-Ch-fi-Ch").to_a
          day_buttons.pop until day_buttons.last.text == "31"

          day_button = day_buttons.last
          day_button.click

          filter_btn = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[5]/div")
          filter_btn.click

          filter_all_btn = iframe.element(xpath: "/html/body/div[14]/div[1]")
          filter_all_btn.click

          download_button = iframe.element(xpath: "/html/body/div[9]/div[2]/div/div/div/div[9]/div")
          download_button.click

          # if i == 0
          agree_to_cfd_stock_terms(iframe)
          sleep(1)
          iframe.element(xpath: "/html/body/div[9]/div[5]/div/div/div[2]/div[3]/div[1]/div/div[4]/div[1]/div/div/input").send_keys("fjohnstone@usertesting.com")
          iframe.element(xpath: "/html/body/div[9]/div[5]/div/div/div[2]/div[3]/div[1]/div/div[4]/div[2]/div/div/input").send_keys("R@unchywasp1")
          submit_button = iframe.element(xpath: "/html/body/div[9]/div[5]/div/div/div[2]/div[3]/div[1]/div/div[4]/div[4]/div[1]/div")

          sleep(1)

          submit_button.click
          # end

          retry_until = Time.now + 240.seconds

          begin
            save_csv_button = iframe.element(xpath: "/html/body/div[9]/div[1]/div[5]/div/div[2]/div[1]")
            save_csv_button.click

            @driver.goto("https://www.dukascopy.com/plugins/fxMarketWatch/?historical_data")
            sleep(1)
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
end