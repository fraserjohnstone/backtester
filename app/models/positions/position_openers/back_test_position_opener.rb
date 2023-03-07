module Positions
  module PositionOpeners
    class BackTestPositionOpener
      attr_reader :strategy

      delegate :runner, to: :strategy

      def initialize(strategy:)
        @strategy = strategy
      end

      def open_market_buy(tick:)
        strategy.log.info("#{self.class} --- Opening market buy")
        open_order(tick: tick, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET, open_price: tick.ask, state: Position::STATE_OPEN)
      end

      def open_market_sell(tick:)
        strategy.log.info("#{self.class} --- Opening market sell")
        open_order(tick: tick, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_MARKET, open_price: tick.bid, state: Position::STATE_OPEN)
      end

      def open_limit_buy(tick:, open_price:)
        strategy.log.info("#{self.class} --- Opening limit buy")
        open_order(tick: tick, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_LIMIT, open_price: open_price, state: Position::STATE_PENDING, expires: true)
      end

      def open_limit_sell(tick:, open_price:)
        strategy.log.info("#{self.class} --- Opening limit sell")
        open_order(tick: tick, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_LIMIT, open_price: open_price, state: Position::STATE_PENDING, expires: true)
      end

      def open_stop_buy(tick:, open_price:)
        strategy.log.info("#{self.class} --- Opening stop buy")
        open_order(tick: tick, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_STOP, open_price: open_price, state: Position::STATE_PENDING, expires: true)
      end

      def open_stop_sell(tick:, open_price:)
        strategy.log.info("#{self.class} --- Opening stop sell")
        open_order(tick: tick, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_STOP, open_price: open_price, state: Position::STATE_PENDING, expires: true)
      end

      def trigger_pending_position(position:, open_price:)
        position.update(
          state: Position::STATE_OPEN,
          open_price: open_price,
        )
        strategy.log.info("#{self.class} --- Pending position triggered")
        position.attributes.to_h.each_pair { |k, v| strategy.log.info("#{self.class} --- --- #{k}: #{v}") }
      end

      private

      def open_order(tick:, bias:, position_type:, open_price:, state:, expires: false)
        runner.positions.create!(
          position_params(
            open_price: open_price,
            tick: tick,
            bias: bias,
            position_type: position_type,
            state: state,
            expires: expires
          )
        ).tap do |position|
          strategy.log.info("#{self.class} --- Position opened")
          position.attributes.to_h.each_pair { |k, v| strategy.log.info("#{self.class} --- --- #{k}: #{v}") }
          track_position(position: position)
        end
      end

      def position_params(open_price:, tick:, bias:, position_type:, state:, expires:)
        {
          state: state,
          symbol: tick.symbol,
          opened_at: tick.date_time,
          open_price: open_price,
          bias: bias,
          stop_loss_price: stop_loss_price(tick: tick, bias: bias, open_price: open_price),
          original_stop_loss_price: stop_loss_price(tick: tick, bias: bias, open_price: open_price),
          lot_size: lot_size(tick: tick),
          risk_as_money: risk_as_money,
          commission_as_money: commission_as_money,
          position_type: position_type,
          gross_profit: 0.0
        }.tap do |params|
          if strategy.runner.take_profit?
            take_profit_distance = strategy.stop_loss_distance(symbol: tick.symbol) * strategy.runner.target_profit_to_loss_ratio
            take_profit_price = bias == Position::BIAS_BUY ? open_price + take_profit_distance : open_price - take_profit_distance
            params[:take_profit_price] = take_profit_price
          end

          if expires
            params[:expires_at] = tick.date_time + strategy.runner.pending_position_expiry_period
          end
        end
      end

      def stop_loss_price(tick:, bias:, open_price:)
        bias == Position::BIAS_SELL ? open_price + strategy.stop_loss_distance(symbol: tick.symbol) : open_price - strategy.stop_loss_distance(symbol: tick.symbol)
      end

      def risk_as_money
        strategy.runner.account.current_balance * (strategy.runner.risk_pct * 0.01)
      end

      def lot_size(tick:)
        if forex_symbol?(symbol: tick.symbol)
          (risk_as_money / (strategy.stop_loss_distance(symbol: tick.symbol) * 100000)).round(2)
        elsif stock_symbol?(symbol: tick.symbol)
          risk_as_money / strategy.stop_loss_distance(symbol: tick.symbol).round(2)
        end * strategy.lot_size_modifier
      end

      def commission_as_money
        (risk_as_money * 0.01) * runner.commission_pct
      end

      def track_position(position:)
        if position.sell?
          strategy.position_tracker.track_sell_position(position: position)
        else
          strategy.position_tracker.track_buy_position(position: position)
        end
      end

      def stock_symbol?(symbol:)
        Symbols::US_STOCKS.include?(symbol)
      end

      def forex_symbol?(symbol:)
        Symbols::FOREX.include?(symbol)
      end
    end
  end
end