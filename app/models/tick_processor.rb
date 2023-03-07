class TickProcessor
  def process(tick:, strategy:)
    # Close open orders on profit
    close_sells_for_profit(tick: tick, strategy: strategy) if can_close_sell_for_profit?(strategy: strategy, tick: tick)
    close_buys_for_profit(tick: tick, strategy: strategy) if can_close_buy_for_profit?(strategy: strategy, tick: tick)

    # close orders on loss (Back Test only)
    close_sells_for_loss(tick: tick, strategy: strategy) if can_close_sell_for_loss?(tick: tick, strategy: strategy)
    close_buys_for_loss(tick: tick, strategy: strategy) if can_close_buy_for_loss?(tick: tick, strategy: strategy)

    # expire/destroy pending orders (Back Test Only)
    expire_pending_sells(tick: tick, strategy: strategy) if pending_sell_expired?(tick: tick, strategy: strategy)
    expire_pending_buys(tick: tick, strategy: strategy) if pending_buy_expired?(tick: tick, strategy: strategy)

    # Trail stops on open orders
    trail_stops(tick: tick, strategy: strategy) if can_trail_stop?(tick: tick, strategy: strategy)

    # trigger pending positions
    trigger_pending_sells(tick: tick, strategy: strategy) if pending_limit_sell_triggerable?(tick: tick, strategy: strategy)
    trigger_pending_buys(tick: tick, strategy: strategy) if pending_limit_buy_triggerable?(tick: tick, strategy: strategy)

    trigger_pending_sells(tick: tick, strategy: strategy) if pending_stop_sell_triggerable?(tick: tick, strategy: strategy)
    trigger_pending_buys(tick: tick, strategy: strategy) if pending_stop_buy_triggerable?(tick: tick, strategy: strategy)

    # Break even on open orders

    # Open new orders
    if tick.spread < strategy.max_spread_for(symbol: tick.symbol)
      open_new_sells(tick: tick, strategy: strategy) unless strategy.position_tracker.already_selling?(symbol: tick.symbol)
      open_new_buys(tick: tick, strategy: strategy) unless strategy.position_tracker.already_buying?(symbol: tick.symbol)
    end
  end

  def close_sells_for_profit(tick:, strategy:)
    strategy.position_closer.close_position!(position: strategy.position_tracker.current_sell(symbol: tick.symbol), tick: tick)
  end

  def close_buys_for_profit(tick:, strategy:)
    strategy.position_closer.close_position!(position: strategy.position_tracker.current_buy(symbol: tick.symbol), tick: tick)
  end

  def close_sells_for_loss(tick:, strategy:)
    strategy.position_closer.close_position!(position: strategy.position_tracker.current_sell(symbol: tick.symbol), tick: tick)
  end

  def close_buys_for_loss(tick:, strategy:)
    strategy.position_closer.close_position!(position: strategy.position_tracker.current_buy(symbol: tick.symbol), tick: tick)
  end

  def expire_pending_sells(tick:, strategy:)
    strategy.position_closer.expire_pending_position!(position: strategy.position_tracker.current_sell(symbol: tick.symbol))
  end

  def expire_pending_buys(tick:, strategy:)
    strategy.position_closer.expire_pending_position!(position: strategy.position_tracker.current_buy(symbol: tick.symbol))
  end

  def trigger_pending_sells(tick:, strategy:)
    strategy.position_opener.trigger_pending_position(position: strategy.position_tracker.current_sell(symbol: tick.symbol), open_price: tick.bid)
  end

  def trigger_pending_buys(tick:, strategy:)
    strategy.position_opener.trigger_pending_position(position: strategy.position_tracker.current_buy(symbol: tick.symbol), open_price: tick.ask)
  end

  def open_new_sells(tick:, strategy:)
    if strategy.eligible_for_sells?(tick: tick)
      p 1
      strategy.open_sell!(tick: tick)
    end
  end

  def open_new_buys(tick:, strategy:)
    if strategy.eligible_for_buys?(tick: tick)
      strategy.open_buy!(tick: tick)
    end
  end

  def trail_stops(tick:, strategy:)
    strategy.position_updater.trail_stop(tick: tick, position: strategy.position_tracker.current_sell(symbol: tick.symbol)) if current_sell_open?(tick: tick, strategy: strategy)
    strategy.position_updater.trail_stop(tick: tick, position: strategy.position_tracker.current_buy(symbol: tick.symbol)) if current_buy_open?(tick: tick, strategy: strategy)
  end

  private

  def can_trail_stop?(tick:, strategy:)
    return false unless strategy.runner.trail_stops?
    return false unless current_sell_open?(tick: tick, strategy: strategy) || current_buy_open?(tick: tick, strategy: strategy)
    true
  end

  def current_sell_open?(strategy:, tick:)
    strategy.position_tracker.already_selling?(symbol: tick.symbol)
  end

  def current_buy_open?(strategy:, tick:)
    strategy.position_tracker.already_buying?(symbol: tick.symbol)
  end

  def can_close_sell_for_profit?(strategy:, tick:)
    current_sell_open?(strategy: strategy, tick: tick) && strategy.close_sell_for_profit?(tick: tick)
  end

  def can_close_buy_for_profit?(strategy:, tick:)
    current_buy_open?(strategy: strategy, tick: tick) && strategy.close_buy_for_profit?(tick: tick)
  end

  def can_close_sell_for_loss?(strategy:, tick:)
    current_sell_open?(strategy: strategy, tick: tick) && strategy.close_sell_for_loss?(tick: tick)
  end

  def can_close_buy_for_loss?(strategy:, tick:)
    current_buy_open?(strategy: strategy, tick: tick) && strategy.close_buy_for_loss?(tick: tick)
  end

  def pending_sell_expired?(strategy:, tick:)
    pending_sell_exists?(tick: tick, strategy: strategy) && strategy.position_tracker.current_sell(symbol: tick.symbol).expired?(tick: tick)
  end

  def pending_buy_expired?(strategy:, tick:)
    pending_buy_exists?(tick: tick, strategy: strategy) && strategy.position_tracker.current_buy(symbol: tick.symbol).expired?(tick: tick)
  end

  def pending_limit_sell_triggerable?(tick:, strategy:)
    pending_sell_exists?(tick: tick, strategy: strategy) &&
      strategy.position_tracker.current_sell(symbol: tick.symbol).position_type == Position::POSITION_TYPE_LIMIT &&
      tick.bid >= strategy.position_tracker.current_sell(symbol: tick.symbol).open_price
  end

  def pending_limit_buy_triggerable?(tick:, strategy:)
    pending_buy_exists?(tick: tick, strategy: strategy) &&
      strategy.position_tracker.current_buy(symbol: tick.symbol).position_type == Position::POSITION_TYPE_LIMIT &&
      tick.ask <= strategy.position_tracker.current_buy(symbol: tick.symbol).open_price
  end

  def pending_stop_sell_triggerable?(tick:, strategy:)
    pending_sell_exists?(tick: tick, strategy: strategy) &&
      strategy.position_tracker.current_sell(symbol: tick.symbol).position_type == Position::POSITION_TYPE_STOP &&
      tick.bid <= strategy.position_tracker.current_sell(symbol: tick.symbol).open_price
  end

  def pending_stop_buy_triggerable?(tick:, strategy:)
    pending_buy_exists?(tick: tick, strategy: strategy) &&
      strategy.position_tracker.current_buy(symbol: tick.symbol).position_type == Position::POSITION_TYPE_STOP &&
      tick.ask >= strategy.position_tracker.current_buy(symbol: tick.symbol).open_price
  end

  def pending_sell_exists?(tick:, strategy:)
    strategy.position_tracker.already_selling?(symbol: tick.symbol) && strategy.position_tracker.current_sell(symbol: tick.symbol).pending?
  end

  def pending_buy_exists?(tick:, strategy:)
    strategy.position_tracker.already_buying?(symbol: tick.symbol) && strategy.position_tracker.current_buy(symbol: tick.symbol).pending?
  end
end