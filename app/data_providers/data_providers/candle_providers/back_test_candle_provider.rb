module DataProviders
  module CandleProviders
    class BackTestCandleProvider
      DEFAULT_LOOK_BACK_COUNT = 300

      attr_reader \
          :symbols,
          :look_back_count,
          :in_memory_h4_candles,
          :in_memory_h2_candles,
          :in_memory_h1_candles,
          :in_memory_m15_candles,
          :in_memory_m5_candles,
          :strategy

      def initialize(symbols:, strategy:, look_back_count: DEFAULT_LOOK_BACK_COUNT)
        @symbols = symbols
        @strategy = strategy
        @look_back_count = look_back_count

        @in_memory_h4_candles = {}
        @in_memory_h2_candles = {}
        @in_memory_h1_candles = {}
        @in_memory_m15_candles = {}
        @in_memory_m5_candles = {}
      end

      def all_candles(timeframe:)
        return in_memory_h4_candles.each_with_object({}) { |(symbol, candles), h| h[symbol] = candles[..-2] } if timeframe == Candle::TIMEFRAME_H4
        return in_memory_h2_candles.each_with_object({}) { |(symbol, candles), h| h[symbol] = candles[..-2] } if timeframe == Candle::TIMEFRAME_H2
        return in_memory_h1_candles.each_with_object({}) { |(symbol, candles), h| h[symbol] = candles[..-2] } if timeframe == Candle::TIMEFRAME_H1
        return in_memory_m15_candles.each_with_object({}) { |(symbol, candles), h| h[symbol] = candles[..-2] } if timeframe == Candle::TIMEFRAME_M15
        return in_memory_m5_candles.each_with_object({}) { |(symbol, candles), h| h[symbol] = candles[..-2] } if timeframe == Candle::TIMEFRAME_M5
      end

      def h4_candles(tick_date_time:, symbol:)
        if in_memory_h4_candles.empty? || in_memory_h4_candles[symbol].nil?
          strategy.log.info("#{self.class} --- Loading all #{symbol} H4 candles for tick at #{tick_date_time}")
          candles = Candle.where(symbol: symbol, timeframe: "h4", open_time: ..tick_date_time).last(look_back_count + 1)
          in_memory_h4_candles[symbol] = candles
        elsif tick_date_time > in_memory_h4_candles[symbol].last.close_time
          candle = Candle.where(symbol: symbol, timeframe: "h4", open_time: ..tick_date_time).last
          in_memory_h4_candles[symbol].append(candle).drop(1)
        end
        in_memory_h4_candles[symbol][..-2]
      end

      def h2_candles(tick_date_time:, symbol:)
        if in_memory_h2_candles.empty? || in_memory_h2_candles[symbol].nil?
          strategy.log.info("#{self.class} --- Loading all #{symbol} h2 candles for tick at #{tick_date_time}")
          candles = Candle.where(symbol: symbol, timeframe: "h2", open_time: ..tick_date_time).last(look_back_count + 1)
          in_memory_h2_candles[symbol] = candles
        elsif tick_date_time > in_memory_h2_candles[symbol].last.close_time
          candle = Candle.where(symbol: symbol, timeframe: "h2", open_time: ..tick_date_time).last
          in_memory_h2_candles[symbol].append(candle).drop(1)
        end
        in_memory_h2_candles[symbol][..-2]
      end

      def h1_candles(tick_date_time:, symbol:)
        if in_memory_h1_candles.empty? || in_memory_h1_candles[symbol].nil?
          strategy.log.info("#{self.class} --- Loading all #{symbol} h1 candles for tick at #{tick_date_time}")
          candles = Candle.where(symbol: symbol, timeframe: "h1", open_time: ..tick_date_time).last(look_back_count + 1)
          in_memory_h1_candles[symbol] = candles
        elsif tick_date_time > in_memory_h1_candles[symbol].last.close_time
          candle = Candle.where(symbol: symbol, timeframe: "h1", open_time: ..tick_date_time).last
          in_memory_h1_candles[symbol].append(candle).drop(1)
        end
        in_memory_h1_candles[symbol][..-2]
      end

      def m15_candles(tick_date_time:, symbol:)
        if in_memory_m15_candles.empty? || in_memory_m15_candles[symbol].nil?
          strategy.log.info("#{self.class} --- Loading all #{symbol} m15 candles for tick at #{tick_date_time}")
          candles = Candle.where(symbol: symbol, timeframe: "m15", open_time: ..tick_date_time).last(look_back_count + 1)
          in_memory_m15_candles[symbol] = candles
        elsif tick_date_time > in_memory_m15_candles[symbol].last.close_time
          candle = Candle.where(symbol: symbol, timeframe: "m15", open_time: ..tick_date_time).last
          in_memory_m15_candles[symbol].append(candle).drop(1)
        end
        in_memory_m15_candles[symbol][..-2]
      end

      def m5_candles(tick_date_time:, symbol:)
        if in_memory_m5_candles.empty? || in_memory_m5_candles[symbol].nil?
          strategy.log.info("#{self.class} --- Loading all #{symbol} m5 candles for tick at #{tick_date_time}")
          candles = Candle.where(symbol: symbol, timeframe: "m5", open_time: ..tick_date_time).last(look_back_count + 1)
          in_memory_m5_candles[symbol] = candles
        elsif tick_date_time > in_memory_m5_candles[symbol].last.close_time
          candle = Candle.where(symbol: symbol, timeframe: "m5", open_time: ..tick_date_time).last
          in_memory_m5_candles[symbol].append(candle).drop(1)
        end
        in_memory_m5_candles[symbol][..-2]
      end
    end
  end
end