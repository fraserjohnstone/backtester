FactoryBot.define do
  factory :tick do
    symbol { "EURUSD" }
    uuid { SecureRandom.uuid }
    date_time { DateTime.parse("2019-05-18 14:22:21") }
    bid { 1.231744 }
    ask { 1.231832 }
    ask_volume { 0.76 }
    bid_volume { 0.45 }
    spread { 0.000088 }
    minute_of_day { 22 }
  end
end