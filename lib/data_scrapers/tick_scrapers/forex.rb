require "watir"

module DataScrapers
  module TickScrapers
    class Forex < BaseTickDataScraper
      SYMBOL_X_PATHS = {
        "AUDCAD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[181]",
        "AUDCHF" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[182]",
        "AUDJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[183]",
        "AUDNZD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[184]",
        "AUDUSD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[186]",
        "CADCHF" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[272]",
        "CADJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[274]",
        "CHFJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[303]",
        "EURAUD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[449]",
        "EURCAD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[450]",
        "EURCHF" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[451]",
        "EURGBP" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[454]",
        "EURJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[457]",
        "EURNZD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[459]",
        "EURUSD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[464]",
        "GBPAUD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[532]",
        "GBPCHF" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[534]",
        "GBPJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[535]",
        "GBPNZD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[536]",
        "GBPUSD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[537]",
        "NZDCAD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[817]",
        "NZDCHF" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[818]",
        "NZDJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[819]",
        "NZDUSD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[820]",
        "USDCAD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1123]",
        "USDCHF" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1124]",
        "USDJPY" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1131]",
        "XAGUSD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1211]",
        "XAUUSD" => "/html/body/div[9]/div[1]/div[4]/div/div/ul/li[1212]"
      }

      DATES_TO_SKIP = [
        DateTime.parse("2016-01-01"),
        DateTime.parse("2017-12-31"),
        DateTime.parse("2019-05-26"),
        DateTime.parse("2021-01-01"),
        DateTime.parse("2017-12-24"),
        DateTime.parse("2017-01-01"),
        DateTime.parse("2022-12-25")
      ]
      TARGET_BTN_XPATH = "/html/body/div[9]/div[1]/div[3]/ul/li[2]"
    end
  end
end