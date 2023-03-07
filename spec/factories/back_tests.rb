FactoryBot.define do
  factory :back_test do
    back_test_account
    strategy_class { "SomeTestStrategy" }
    symbols { %w[AUDUSD USDCAD EURUSD] }
  end
end