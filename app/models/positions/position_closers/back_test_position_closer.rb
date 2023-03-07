module Positions
  module PositionClosers
    class BackTestPositionCloser
      attr_reader :strategy

      def initialize(strategy:)
        @strategy = strategy
      end

      def close_position!(position:, tick:)
        strategy.log.info("#{self.class} --- Closing position")
        gross_profit = position.current_gross_profit(tick: tick)

        position.update!(
          close_price: close_price(position: position, tick: tick),
          closed_at: tick.date_time,
          state: Position::STATE_CLOSED,
          gross_profit: gross_profit
        )

        strategy.log.info("#{self.class} --- Position closed")
        position.attributes.to_h.each_pair { |k, v| strategy.log.info("#{self.class} --- --- #{k}: #{v}") }

        if position.sell?
          strategy.position_tracker.release_sell_position(position: position)
        elsif position.buy?
          strategy.position_tracker.release_buy_position(position: position)
        end

        if position.hedge_position.present? && position.hedge_position.state != Position::STATE_CLOSED
          close_position!(position: position.hedge_position, tick: tick)
        end

        if position.hedge_position_for.present? && position.hedge_position_for.state != Position::STATE_CLOSED
          close_position!(position: position.hedge_position_for, tick: tick)
        end
      end

      def expire_pending_position!(position:)
        strategy.log.info("#{self.class} --- Expiring un-triggered pending position")
        position.destroy.tap do |pos|
          strategy.log.info("#{self.class} --- Position expired")
          pos.attributes.to_h.each_pair { |k, v| strategy.log.info("#{self.class} --- --- #{k}: #{v}") }

          if pos.sell?
            strategy.position_tracker.release_sell_position(position: pos)
          elsif pos.buy?
            strategy.position_tracker.release_buy_position(position: pos)
          end
        end
      end

      private

      def close_price(position:, tick:)
        position.sell? ? tick.ask : tick.bid
      end
    end
  end
end