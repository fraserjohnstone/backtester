class Position < ApplicationRecord
  STATE_PENDING = "state_pending"
  STATE_OPEN = "state_open"
  STATE_CLOSED = "state_closed"

  BIAS_SELL = "bias_sell"
  BIAS_BUY = "bias_buy"

  POSITION_TYPE_LIMIT = "position_type_limit"
  POSITION_TYPE_STOP = "position_type_stop"
  POSITION_TYPE_MARKET = "position_type_market"

  enum state: [
    STATE_PENDING,
    STATE_OPEN,
    STATE_CLOSED
  ]

  enum bias: [
    BIAS_BUY,
    BIAS_SELL
  ]

  enum position_type: [
    POSITION_TYPE_LIMIT,
    POSITION_TYPE_STOP,
    POSITION_TYPE_MARKET
  ]

  attribute :gross_profit, default: 0.0
  attribute :spread_history, default: []
  attribute :time_alive, default: 0.0

  validates_presence_of \
    :symbol,
    :open_price,
    :stop_loss_price,
    :original_stop_loss_price,
    :lot_size,
    :risk_as_money,
    :commission_as_money,
    :opened_at,
    :state,
    :bias,
    :position_type

  scope :open, -> { where(hedge_position_for: nil, state: STATE_OPEN) }
  scope :closed, -> { where(hedge_position_for: nil, state: STATE_CLOSED) }
  scope :pending, -> { where(hedge_position_for: nil, state: STATE_PENDING) }
  scope :buys, -> { where(hedge_position_for: nil, bias: BIAS_BUY) }
  scope :sells, -> { where(hedge_position_for: nil, bias: BIAS_SELL) }
  scope :wins, -> { closed.where("gross_profit > ?", 0.0) }
  scope :losses, -> { closed.where("gross_profit <= ?", 0.0) }

  belongs_to :back_test, optional: true
  belongs_to :hedge_position_for, optional: true, class_name: "Position"
  belongs_to :hedge_position, optional: true, class_name: "Position"

  def open?
    state == STATE_OPEN
  end

  def pending?
    state == STATE_PENDING
  end

  def win?
    return true if sell? && open_price > close_price
    return true if buy? && open_price < close_price
  end

  def stop_loss_distance
    (open_price - original_stop_loss_price).abs
  end

  def abs_current_change_in_price(tick:)
    if sell?
      (tick.ask - open_price).abs
    elsif buy?
      (tick.bid - open_price).abs
    end
  end

  def abs_change_pct_of_stop(tick:)
    abs_current_change_in_price(tick: tick) / stop_loss_distance
  end

  def abs_profit(tick:)
    risk_as_money * abs_change_pct_of_stop(tick: tick)
  end

  def current_gross_profit(tick:)
    if (sell? && tick.ask >= open_price) || (buy? && tick.bid <= open_price)
      return -abs_profit(tick: tick)
    end

    abs_profit(tick: tick)
  end

  def update_current_gross_profit(tick:)
    update(gross_profit: current_gross_profit(tick: tick))
  end

  def net_profit
    gross_profit - commission_as_money
  end

  def sell?
    bias == Position::BIAS_SELL
  end

  def buy?
    bias == Position::BIAS_BUY
  end

  def expired?(tick:)
    tick.date_time > expires_at
  end

  def pct_change
    gross_profit/risk_as_money
  end

  def gross_profit
    return super unless hedge_position.present?
    super - hedge_position.gross_profit
  end

  def best_candle_timeframe
    return "m5" unless time_alive > 4.hours
    return "m15" if time_alive > 4.hours && time_alive < 12.hours
    return "h1" if time_alive > 12.hours && time_alive < 72.hours
    return "h4" if time_alive > 72.hours
  end
end