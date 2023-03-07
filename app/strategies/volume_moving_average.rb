class VolumeMovingAverage < Strategy
  LOOK_BACK_PERIOD = 5

  def setup(back_test:, live_run:)
    super

    @h1_atr = {}
    @h1_short_pfe = {}
    @h1_long_pfe = {}
    # @h1_ema_24 = {}
  end

  def eligible_for_sells?(tick:)
    return false unless tick.spread < max_spread_for(symbol: tick.symbol)
    return false unless @h1_long_pfe[tick.symbol] < -20 && @h1_short_pfe[tick.symbol] < -10

    true
  end

  def eligible_for_buys?(tick:)
    return false unless tick.spread < max_spread_for(symbol: tick.symbol)
    return false unless @h1_long_pfe[tick.symbol] > 20 && @h1_short_pfe[tick.symbol] > 10

    true
  end

  def update_h1_candle_indicators(date_time:, symbol:)
    @h1_atr[symbol] = indicators.atr(candles: @h1_candles[symbol].last(16)).last.atr
    @h1_short_pfe[symbol] = indicators.pfes(candles: @h1_candles[symbol].last(48), period: 8).last
    @h1_long_pfe[symbol] = indicators.pfes(candles: @h1_candles[symbol].last(48), period: 16).last
    # @h1_ema_24[symbol] = indicators.ema(candles: @h1_candles[symbol].last(48), period: 24).last.ema
  end

  def stop_loss_distance(symbol:)
    [@h1_atr[symbol] * 3, 10 * pip_value_for(symbol: symbol)].max
  end

  def skip_tick?(tick:)
    return false unless tick.spread >= max_spread_for(symbol: tick.symbol)
    return false unless !position_tracker.already_selling?(symbol: tick.symbol) && !position_tracker.already_buying?(symbol: tick.symbol)

    true
  end
end
