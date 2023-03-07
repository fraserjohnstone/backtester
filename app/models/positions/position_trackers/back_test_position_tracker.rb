module Positions
  module PositionTrackers
    class BackTestPositionTracker
      attr_reader :strategy

      def initialize(strategy:)
        @strategy = strategy
        @open_sells = {}
        @open_buys = {}
      end

      def track_sell_position(position:)
        @open_sells[position.symbol] = position
        strategy.log.info("#{self.class} --- Tracking new sell position: #{position.id}")
      end

      def track_buy_position(position:)
        @open_buys[position.symbol] = position
        strategy.log.info("#{self.class} --- Tracking new buy position: #{position.id}")
      end

      def release_sell_position(position:)
        @open_sells[position.symbol] = nil
        strategy.log.info("#{self.class} --- Released sell position: #{position.id}")
      end

      def release_buy_position(position:)
        @open_buys[position.symbol] = nil
        strategy.log.info("#{self.class} --- Released buy position: #{position.id}")
      end

      def already_selling?(symbol:)
        current_sell(symbol: symbol).present?
      end

      def already_buying?(symbol:)
        current_buy(symbol: symbol).present?
      end

      def current_sell(symbol:)
        @open_sells[symbol]
      end

      def current_buy(symbol:)
        @open_buys[symbol]
      end
    end
  end
end