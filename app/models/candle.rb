class Candle < ApplicationRecord
  NAMESPACE_ID = "2fdc51a0-6f65-4a18-9c77-5333d05c0db1"

  default_scope { order(open_time: :asc) }

  validates_presence_of :uuid, :open, :high, :low, :close, :volume, :symbol, :timeframe, :open_time

  TIMEFRAME_M5 = "m5"
  TIMEFRAME_M15 = "m15"
  TIMEFRAME_H1 = "h1"
  TIMEFRAME_H2 = "h2"
  TIMEFRAME_H4 = "h4"

  def to_h
    {
      open: open,
      high: high,
      low: low,
      close: close,
      date_time: open_time,
      volume: volume,
      symbol: symbol,
      timeframe: timeframe
    }
  end

  def close_time
    if timeframe == TIMEFRAME_H4
      open_time + 4.hours
    elsif timeframe == TIMEFRAME_H2
      open_time + 2.hours
    elsif timeframe == TIMEFRAME_H1
      open_time + 1.hour
    elsif timeframe == TIMEFRAME_M15
      open_time + 15.minutes
    elsif timeframe == TIMEFRAME_M5
      open_time + 5.minutes
    end
  end

  def bearish?
    open > close
  end

  def bullish?
    close > open
  end

  def body
    (open - close).abs
  end

  def range
    (high - low).abs
  end

  def top_wick
    if bullish?
      high - close
    else
      high - open
    end
  end

  def bottom_wick
    if bullish?
      open - low
    else
      close - low
    end
  end

  def percent_of_body(pct: 0.5)
    if bullish?
      open + (body * pct)
    else
      close + (body * pct)
    end
  end

  def bearish_pin_bar?
    top_wick >= (bottom_wick * 3) && range >= body * 3
  end

  def bullish_pin_bar?
    bottom_wick >= (top_wick * 3) && range >= (body * 3)
  end
end