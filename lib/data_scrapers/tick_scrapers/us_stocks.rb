require "watir"

module DataScrapers
  module TickScrapers
    class UsStocks < BaseTickDataScraper
      SYMBOL_X_PATHS = {
        # "AAPL" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[93]",
        # "TSLA" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1087]",
        # "MSFT" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[777]",
        # "BRKB" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[255]",
        # "AMZN" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[158]",
        # "GOOGL" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[563]",
        # "GOOG" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[562]",
        # "NVDA" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[810]",
        # "XOM" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1223]",
        # "VZ" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1178]",
        # "PFE" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[866]",
        # "JPM" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[657]",
        # "BABA" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[206]",
        # "V" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1147]",
        # "ORCL" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[843]",
        # "BAC" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[207]",
        # "ACN" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[106]",
        # "DIS" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[381]",
        # "NFLX" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[793]",
        # "GM" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[559]",
        "INTC" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[624]",
        "CVNA" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[355]"
      }

      DATES_TO_SKIP = []
      TARGET_BTN_XPATH = "/html/body/div[9]/div[1]/div[3]/ul/li[35]"
      START_DATE = DateTime.parse("2017-01-01")
      END_DATE = DateTime.parse("2022-12-31")

      private def agree_to_cfd_stock_terms(iframe)
        sleep(1)
        agree_btn = iframe.element(xpath: "/html/body/div[9]/div[7]/div[3]/button[1]")
        agree_btn.click
      end
    end
  end
end