module Positions
  module PositionUpdaters
    class BackTestPositionUpdater
      attr_reader :strategy

      def initialize(strategy:)
        @strategy = strategy
      end

      def trail_stop(tick:, position:)
        if position.bias == Position::BIAS_SELL
          trail_sell(tick: tick, position: position)
        elsif position.bias == Position::BIAS_BUY
          trail_buy(tick: tick, position: position)
        end
      end

      private

      def trail_sell(tick:, position:)
        proposed_new_stop = tick.ask + position.stop_loss_distance

        if proposed_new_stop < position.stop_loss_price
          position.update(stop_loss_price: proposed_new_stop)
        end
      end

      def trail_buy(tick:, position:)
        proposed_new_stop = tick.bid - position.stop_loss_distance

        if proposed_new_stop > position.stop_loss_price
          position.update(stop_loss_price: proposed_new_stop)
        end
      end
    end
  end
end