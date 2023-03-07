FactoryBot.define do
  factory :position, aliases: [:open_position] do
    symbol { "EURUSD" }
    open_price { 0.9234 }
    stop_loss_price { 0.9100 }
    original_stop_loss_price { 0.9100 }
    lot_size { 1.2 }
    risk_as_money { 75.33 }
    commission_as_money { 1.23 }
    opened_at { DateTime.parse("2019-03-02 06:00") }
    state { Position::STATE_OPEN }


    factory :pending_position do
      state { Position::STATE_PENDING }
      expires_at { DateTime.now + 2.days }
    end

    factory :closed_position do
      state { Position::STATE_CLOSED }
      closed_at { DateTime.now - 1.hour }
    end
  end
end