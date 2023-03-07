FactoryBot.define do
  factory :candle do
    uuid { SecureRandom.uuid }
    symbol { "EURUSD" }
    open { Faker::Number.between(from: 0.8, to: 1.2).round(6) }
    close { Faker::Number.between(from: 0.8, to: 1.2).round(6) }
    high { Faker::Number.between(from: 1.3, to: 1.6).round(6) }
    low { Faker::Number.between(from: 0.6, to: 0.8).round(6) }
    volume { Faker::Number.between(from: 1.0, to: 1.8).round(2) }
    timeframe { "h1" }
    open_time { DateTime.parse("2020-04-01 07:00") }
  end
end