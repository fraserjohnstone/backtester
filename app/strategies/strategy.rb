class Strategy < ApplicationRecord
  include Modules::Loggable
  include SeriesHelper

  class IntentionalInterruption < StandardError; end
  class NotBackTestError < StandardError; end

  DEFAULT_RELEVANT_CANDLE_TIMEFRAMES = ["m15", "h4"]
  DEFAULT_STOP_LOSS_DISTANCE = 10
  UPDATE_PERIOD = 10_000

  has_many :back_tests

  validates_presence_of :relevant_candle_timeframes

  attribute :relevant_candle_timeframes, default: DEFAULT_RELEVANT_CANDLE_TIMEFRAMES

  def setup(back_test:, live_run:)
    if back_test.present?
      @runner = back_test
    else
      @runner = live_run
    end

    @next_h4_candle_due_times = {}
    @next_h2_candle_due_times = {}
    @next_h1_candle_due_times = {}
    @next_m15_candle_due_times = {}
    @next_m5_candle_due_times = {}

    @h4_candles = {}
    @h2_candles = {}
    @h1_candles = {}
    @m15_candles = {}
    @m5_candles = {}

    @ticks_processed = 0
    @ticks_skipped = 0

    @last_period_check_in = DateTime.now
    @minute_count = 0
  end

  def run!(back_test: nil, live_run: nil)
    setup(back_test: back_test, live_run: live_run)



    with_logging do
      while tick_provider.more_ticks? do
        p "there are symbols"
        next_minute_ticks = tick_provider.get_next_ticks
        current_model_progress_date_time = tick_provider.current_date_time
        current_minute = current_model_progress_date_time.min

        if @minute_count % [(60.0/@runner.symbols.count).ceil, 60].max == 0
          @runner.update(progress_date: current_model_progress_date_time)
        end

        @minute_count += 1

        @runner.symbols.each do |symbol|
          if current_minute == 0 && next_minute_ticks[symbol].any?
            if position_tracker.already_selling?(symbol: symbol)
              pos = position_tracker.current_sell(symbol: symbol)
              pos.update_current_gross_profit(tick: next_minute_ticks[symbol].first)
              pos.update(time_alive: next_minute_ticks[symbol].first.date_time - pos.opened_at)
            end

            if position_tracker.already_buying?(symbol: symbol)
              pos = position_tracker.current_buy(symbol: symbol)
              pos.update_current_gross_profit(tick: next_minute_ticks[symbol].first)
              pos.update(time_alive: next_minute_ticks[symbol].first.date_time - pos.opened_at)
            end
          end
        end

        next_minute_ticks.each_pair do |symbol, ticks_for_symbol|
          if current_minute % 5 == 0
            update_candle_based_indicators(date_time: current_model_progress_date_time, symbol: symbol)
          end

          raise IntentionalInterruption if @runner.reload.finished?
          next if ticks_for_symbol.empty?

          ticks_for_symbol.each_with_index do |tick, i|
            if skip_tick?(tick: tick)
              @ticks_skipped += 1
            else
              process_tick_data_for_symbol(tick: tick)
              @ticks_processed += 1
            end
            p "#{@ticks_processed + @ticks_skipped}"

            if (@ticks_skipped + @ticks_processed) % UPDATE_PERIOD == 0
              p "updating"
              @runner.update(
                ticks_processed_in_period: @runner.ticks_processed_in_period << {
                  ticks_skipped: @ticks_skipped,
                  ticks_processed: @ticks_processed,
                  total_ticks_seen: @ticks_skipped + @ticks_processed,
                  time_taken: DateTime.now - @last_period_check_in
                }
              )
              @last_period_check_in = DateTime.now
              @ticks_skipped = 0
              @ticks_processed = 0
            end
          end
        end
      end

      @runner.organically_finish!
    rescue IntentionalInterruption => e
      log.info("Process stopped - Manually terminated")
      raise
    rescue
      log.info("Process stopped - Error")
      @runner.exception_finish!
      raise
    end
  end

  def process_tick_data_for_symbol(tick:)
    tick_processor.process(tick: tick, strategy: self)
  end

  def update_candle_based_indicators(date_time:, symbol:)
    relevant_candle_timeframes.each do |tf|
      if eval("@next_#{tf}_candle_due_times")[symbol].nil? || date_time > eval("@next_#{tf}_candle_due_times")[symbol]
        eval("@#{tf}_candles")[symbol] = candle_provider.send("#{tf}_candles", tick_date_time: date_time, symbol: symbol)
        eval("update_#{tf}_candle_indicators(date_time: date_time, symbol: symbol)")
        eval("@next_#{tf}_candle_due_times")[symbol] = (date_time + 4.hour).beginning_of_hour
      end
    end

    # if relevant_candle_timeframes.include?("h4") && (@next_h4_candle_due_times[symbol].nil? || date_time > (@next_h4_candle_due_times[symbol]))
    #   @h4_candles[symbol] = candle_provider.h4_candles(tick_date_time: date_time, symbol: symbol)
    #   update_h4_candle_indicators(date_time: date_time, symbol: symbol)
    #   @next_h4_candle_due_times[symbol] = (date_time + 4.hour).beginning_of_hour
    # end
    #
    # if relevant_candle_timeframes.include?("h2") && (@next_h2_candle_due_times[symbol].nil? || date_time > (@next_h2_candle_due_times[symbol]))
    #   @h2_candles[symbol] = candle_provider.h2_candles(tick_date_time: date_time, symbol: symbol)
    #   update_h2_candle_indicators(date_time: date_time, symbol: symbol)
    #   @next_h2_candle_due_times[symbol] = (date_time + 2.hour).beginning_of_hour
    # end
    #
    # if relevant_candle_timeframes.include?("h1") && (@next_h1_candle_due_times[symbol].nil? || date_time > (@next_h1_candle_due_times[symbol]))
    #   @h1_candles[symbol] = candle_provider.h1_candles(tick_date_time: date_time, symbol: symbol)
    #   update_h1_candle_indicators(date_time: date_time, symbol: symbol)
    #   @next_h1_candle_due_times[symbol] = (date_time + 1.hour).beginning_of_hour
    # end
    #
    # if relevant_candle_timeframes.include?("m15") && (@next_m15_candle_due_times[symbol].nil? || date_time > (@next_m15_candle_due_times[symbol]))
    #   @m15_candles[symbol] = candle_provider.m15_candles(tick_date_time: date_time, symbol: symbol)
    #   update_m15_candle_indicators(date_time: date_time, symbol: symbol)
    #   @next_m15_candle_due_times[symbol] = (date_time + 15.minutes).beginning_of_minute
    # end
    #
    # if relevant_candle_timeframes.include?("m5") && (@next_m5_candle_due_times[symbol].nil? || date_time > (@next_m5_candle_due_times[symbol]))
    #   @m5_candles[symbol] = candle_provider.m5_candles(tick_date_time: date_time, symbol: symbol)
    #   update_m5_candle_indicators(date_time: date_time, symbol: symbol)
    #   @next_m5_candle_due_times[symbol] = (date_time + 5.minutes).beginning_of_minute
    # end
  end

  # utility classes

  def tick_provider
    @tick_provider ||= if back_test?
                         DataProviders::TickProviders::BackTestTickProvider.new(
                           symbols: @runner.symbols,
                           start_date: @runner.start_date,
                           end_date: @runner.end_date,
                           strategy: self
                         )
                       else
                         # implement a live data provider class
                       end
  end

  def candle_provider
    @candle_provider ||= if back_test?
                         DataProviders::CandleProviders::BackTestCandleProvider.new(symbols: @runner.symbols, strategy: self)
                       else
                         # implement a live data provider class
                       end
  end

  def position_opener
    @position_opener ||= if back_test?
                           Positions::PositionOpeners::BackTestPositionOpener.new(strategy: self)
                         else
                           # implement a live position opener
                         end
  end

  def position_closer
    @position_closer ||= if back_test?
                           Positions::PositionClosers::BackTestPositionCloser.new(strategy: self)
                         else
                           # implement a live position opener
                         end
  end

  def position_tracker
    @position_tracker ||= if back_test?
                            Positions::PositionTrackers::BackTestPositionTracker.new(strategy: self)
                          else
                            # implement live position tracker
                          end
  end

  def position_updater
    @position_updater ||= if back_test?
                            Positions::PositionUpdaters::BackTestPositionUpdater.new(strategy: self)
                          else
                            # implement live position tracker
                          end
  end

  def runner
    @runner
  end

  def tick_processor
    @tick_processor ||= TickProcessor.new
  end

  def indicators
    @indicators ||= Indicators.new
  end

  def pip_value_for(symbol:)
    return 0.01 if Symbols::US_STOCKS.include?(symbol)
    symbol.include?("JPY") ? 0.01 : 0.0001
  end

  def max_spread_for(symbol:)
    @runner.max_spread * pip_value_for(symbol: symbol)
  end

  def skip_tick?(tick:)
    false
  end

  # overridable methods
  def update_h4_candle_indicators(date_time:, symbol:)
    raise "Override in inheriting class"
  end

  def update_h2_candle_indicators(date_time:, symbol:)
    raise "Override in inheriting class"
  end

  def update_h1_candle_indicators(date_time:, symbol:)
    raise "Override in inheriting class"
  end

  def update_m15_candle_indicators(date_time:, symbol:)
    raise "Override in inheriting class"
  end

  def update_m5_candle_indicators(date_time:, symbol:)
    raise "Override in inheriting class"
  end

  def eligible_for_sells?(tick:)
    raise "Override in inheriting class"
  end

  def eligible_for_buys?(tick:)
    raise "Override in inheriting class"
  end

  def stop_loss_distance(symbol:)
    DEFAULT_STOP_LOSS_DISTANCE * pip_value_for(symbol: symbol)
  end

  def close_sell_for_profit?(tick:)
    tick.ask <= position_tracker.current_sell(symbol: tick.symbol).take_profit_price if @runner.take_profit?
  end

  def close_buy_for_profit?(tick:)
    tick.bid >= position_tracker.current_buy(symbol: tick.symbol).take_profit_price if @runner.take_profit?
  end

  def close_sell_for_loss?(tick:)
    tick.ask >= position_tracker.current_sell(symbol: tick.symbol).stop_loss_price
  end

  def close_buy_for_loss?(tick:)
    tick.bid <= position_tracker.current_buy(symbol: tick.symbol).stop_loss_price
  end

  def open_sell!(tick:)
    position_opener.open_market_sell(tick: tick)
  end

  def open_buy!(tick:)
    position_opener.open_market_buy(tick: tick)
  end

  def back_test?
    @runner.class == BackTest
  end

  def underscore_name
    @underscore_name ||= self.class.name.split("::").last.underscore
  end

  def lot_size_modifier
    1
  end
end