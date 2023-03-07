require "rails_helper"

describe TickProcessor do
  let(:instance) { described_class.new }

  let(:tick) { create(:tick) }
  let(:strategy) do
    double(
      take_profit?: take_profit?,
      stop_loss_distance: stop_loss_distance,
      profit_to_loss_ratio: profit_to_loss_ratio,
      position_tracker: position_tracker,
      position_opener: position_opener,
      position_closer: position_closer,
      back_test: back_test,
      log: logger,
      indicators: indicators,
      eligible_for_sells?: eligible_for_sells?,
      eligible_for_buys?: eligible_for_buys?,
      close_sell_for_profit?: close_sell_for_profit?,
      close_buy_for_profit?: close_buy_for_profit?,
      close_sell_for_loss?: close_sell_for_loss?,
      close_buy_for_loss?: close_buy_for_loss?,
      open_sell!: nil,
      open_buy!: nil
    )
  end
  let(:take_profit?) { true }
  let(:stop_loss_distance) { 0.002 }
  let(:profit_to_loss_ratio) { 2 }
  let(:eligible_for_sells?) { false }
  let(:eligible_for_buys?) { false }
  let(:close_sell_for_profit?) { false }
  let(:close_buy_for_profit?) { false }
  let(:close_sell_for_loss?) { false }
  let(:close_buy_for_loss?) { false }
  let(:back_test) { create(:back_test, back_test_account: back_test_account) }
  let(:back_test_account) { create(:back_test_account) }
  let(:position_tracker) do
    instance_double(
      Positions::PositionTrackers::BackTestPositionTracker,
      track_buy_position: nil,
      track_sell_position: nil,
      release_buy_position: nil,
      release_buy_position: nil,
      already_selling?: already_selling?,
      already_buying?: already_buying?,
      current_sell: current_sell,
      current_buy: current_buy
    )
  end
  let(:already_buying?) { false }
  let(:already_selling?) { false }
  let(:current_sell) { create(:open_position, bias: Position::BIAS_BUY, position_type: position_type) }
  let(:current_buy) { create(:open_position, bias: Position::BIAS_SELL, position_type: position_type) }
  let(:position_type) { Position::POSITION_TYPE_MARKET }
  let(:logger) { instance_double(Logger, info: nil) }
  let(:indicators) { instance_double(Indicators) }
  let(:position_opener) do
    instance_double(
      Positions::PositionOpeners::BackTestPositionOpener,
      open_market_buy: nil,
      open_market_sell: nil,
      open_limit_buy: nil,
      open_limit_sell: nil,
      open_stop_buy: nil,
      open_stop_sell: nil,
      trigger_pending_position: nil
    )
  end
  let(:position_closer) do
    instance_double(
      Positions::PositionClosers::BackTestPositionCloser,
      close_position!: nil,
      expire_pending_position!: nil
    )
  end

  describe "#process" do
    subject(:process) { instance.process(tick: tick, strategy: strategy) }

    before do
      allow(instance).to receive(:open_new_sells)
      allow(instance).to receive(:open_new_buys)
      allow(instance).to receive(:close_sells_for_profit)
      allow(instance).to receive(:close_buys_for_profit)
      allow(instance).to receive(:close_sells_for_loss)
      allow(instance).to receive(:close_buys_for_loss)
      allow(instance).to receive(:expire_pending_sells)
      allow(instance).to receive(:expire_pending_buys)
      allow(instance).to receive(:trigger_pending_sells)
      allow(instance).to receive(:trigger_pending_buys)
    end

    it "not attempt to close open positions for a profit", :aggregate_failures do
      expect(instance).to_not receive(:close_sells_for_profit)
      expect(instance).to_not receive(:close_buys_for_profit)
      process
    end

    it "will not attempt to close open positions for a loss", :aggregate_failures do
      expect(instance).to_not receive(:close_sells_for_loss)
      expect(instance).to_not receive(:close_buys_for_loss)
      process
    end

    it "will not attempt to expire any pending positions", :aggregate_failures do
      expect(instance).to_not receive(:expire_pending_sells)
      expect(instance).to_not receive(:expire_pending_buys)
      process
    end

    it "will not attempt to trigger any limit positions", :aggregate_failures do
      expect(instance).to_not receive(:trigger_pending_sells)
      expect(instance).to_not receive(:trigger_pending_buys)
      process
    end

    it "will attempt to open new positions", :aggregate_failures do
      expect(instance).to receive(:open_new_sells).with(tick: tick, strategy: strategy)
      expect(instance).to receive(:open_new_buys).with(tick: tick, strategy: strategy)
      process
    end

    context "we are already selling and already buying", :aggregate_failures do
      let(:already_selling?) { true }
      let(:already_buying?) { true }

      it "will not attempt to close open positions for a profit", :aggregate_failures do
        expect(instance).to_not receive(:close_sells_for_profit)
        expect(instance).to_not receive(:close_buys_for_profit)
        process
      end

      it "will not attempt to expire any pending positions", :aggregate_failures do
        expect(instance).to_not receive(:expire_pending_sells)
        expect(instance).to_not receive(:expire_pending_buys)
        process
      end

      it "will not attempt to trigger any limit positions", :aggregate_failures do
        expect(instance).to_not receive(:trigger_pending_sells)
        expect(instance).to_not receive(:trigger_pending_buys)
        process
      end

      it "will not attempt to open new positions", :aggregate_failures do
        expect(instance).to_not receive(:open_new_sells)
        expect(instance).to_not receive(:open_new_buys)
        process
      end

      context "the strategy knows the position is profitable" do
        let(:close_sell_for_profit?) { true }
        let(:close_buy_for_profit?) { true }

        it "will attempt to close open positions for profit", :aggregate_failures do
          expect(instance).to receive(:close_sells_for_profit).with(tick: tick, strategy: strategy)
          expect(instance).to receive(:close_buys_for_profit).with(tick: tick, strategy: strategy)
          process
        end

        it "will not attempt to close open positions for a loss", :aggregate_failures do
          expect(instance).to_not receive(:close_sells_for_loss)
          expect(instance).to_not receive(:close_buys_for_loss)
          process
        end

        it "will not attempt to expire any pending positions", :aggregate_failures do
          expect(instance).to_not receive(:expire_pending_sells)
          expect(instance).to_not receive(:expire_pending_buys)
          process
        end

        it "will not attempt to trigger any limit positions", :aggregate_failures do
          expect(instance).to_not receive(:trigger_pending_sells)
          expect(instance).to_not receive(:trigger_pending_buys)
          process
        end

        it "will not attempt to open new positions", :aggregate_failures do
          expect(instance).to_not receive(:open_new_sells)
          expect(instance).to_not receive(:open_new_buys)
          process
        end
      end

      context "the strategy knows the position is not profitable" do
        let(:close_sell_for_loss?) { true }
        let(:close_buy_for_loss?) { true }

        it "will not attempt to close open positions for profit", :aggregate_failures do
          expect(instance).to_not receive(:close_sells_for_profit)
          expect(instance).to_not receive(:close_buys_for_profit)
          process
        end

        it "will attempt to close open positions for a loss", :aggregate_failures do
          expect(instance).to receive(:close_sells_for_loss).with(tick: tick, strategy: strategy)
          expect(instance).to receive(:close_buys_for_loss).with(tick: tick, strategy: strategy)
          process
        end

        it "will not attempt to expire any pending positions", :aggregate_failures do
          expect(instance).to_not receive(:expire_pending_sells)
          expect(instance).to_not receive(:expire_pending_buys)
          process
        end

        it "will not attempt to trigger any limit positions", :aggregate_failures do
          expect(instance).to_not receive(:trigger_pending_sells)
          expect(instance).to_not receive(:trigger_pending_buys)
          process
        end

        it "will not attempt to open new positions", :aggregate_failures do
          expect(instance).to_not receive(:open_new_sells)
          expect(instance).to_not receive(:open_new_buys)
          process
        end
      end

      context "the current positions are pending limit orders" do
        let(:current_sell) { create(:pending_position, bias: Position::BIAS_BUY, position_type: position_type, open_price: 10.0) }
        let(:current_buy) { create(:pending_position, bias: Position::BIAS_SELL, position_type: position_type, open_price: 10.0) }

        let(:tick) { create(:tick, bid: 5.0, ask: 15.0 ) }

        let(:position_type) { Position::POSITION_TYPE_LIMIT }

        it "will not attempt to close current positions for profit", :aggregate_failures do
          expect(instance).to_not receive(:close_sells_for_profit)
          expect(instance).to_not receive(:close_buys_for_profit)
          process
        end

        it "will not attempt to close open positions for a loss", :aggregate_failures do
          expect(instance).to_not receive(:close_sells_for_loss)
          expect(instance).to_not receive(:close_buys_for_loss)
          process
        end

        it "will not attempt to expire any pending positions", :aggregate_failures do
          expect(instance).to_not receive(:expire_pending_sells)
          expect(instance).to_not receive(:expire_pending_buys)
          process
        end

        it "will not attempt to trigger any limit positions", :aggregate_failures do
          expect(instance).to_not receive(:trigger_pending_sells)
          expect(instance).to_not receive(:trigger_pending_buys)
          process
        end

        it "will not attempt to open new positions", :aggregate_failures do
          expect(instance).to_not receive(:open_new_sells)
          expect(instance).to_not receive(:open_new_buys)
          process
        end

        context "the pending positions are expired" do
          let(:current_sell) { create(:pending_position, bias: Position::BIAS_BUY, position_type: position_type, expires_at: tick.date_time - 1.day) }
          let(:current_buy) { create(:pending_position, bias: Position::BIAS_SELL, position_type: position_type, expires_at: tick.date_time - 1.hour) }

          it "will attempt to expire any pending positions", :aggregate_failures do
            expect(instance).to receive(:expire_pending_sells).with(tick: tick, strategy: strategy)
            expect(instance).to receive(:expire_pending_buys).with(tick: tick, strategy: strategy)
            process
          end
        end

        context "the limit orders are triggerable" do
          let(:tick) { create(:tick, bid: 15.0, ask: 5.0 ) }

          it "will attempt to trigger any limit positions", :aggregate_failures do
            expect(instance).to receive(:trigger_pending_sells).with(tick: tick, strategy: strategy)
            expect(instance).to receive(:trigger_pending_buys).with(tick: tick, strategy: strategy)
            process
          end
        end
      end

      context "the current positions are pending stop orders" do
        let(:current_sell) { create(:pending_position, bias: Position::BIAS_BUY, position_type: position_type, open_price: 10.0) }
        let(:current_buy) { create(:pending_position, bias: Position::BIAS_SELL, position_type: position_type, open_price: 10.0) }

        let(:tick) { create(:tick, bid: 15.0, ask: 5.0 ) }

        let(:position_type) { Position::POSITION_TYPE_STOP }

        it "will not attempt to close current positions for profit", :aggregate_failures do
          expect(instance).to_not receive(:close_sells_for_profit)
          expect(instance).to_not receive(:close_buys_for_profit)
          process
        end

        it "will not attempt to close open positions for a loss", :aggregate_failures do
          expect(instance).to_not receive(:close_sells_for_loss)
          expect(instance).to_not receive(:close_buys_for_loss)
          process
        end

        it "will not attempt to expire any pending positions", :aggregate_failures do
          expect(instance).to_not receive(:expire_pending_sells)
          expect(instance).to_not receive(:expire_pending_buys)
          process
        end

        it "will not attempt to trigger any limit positions", :aggregate_failures do
          expect(instance).to_not receive(:trigger_pending_sells)
          expect(instance).to_not receive(:trigger_pending_buys)
          process
        end

        it "will not attempt to open new positions", :aggregate_failures do
          expect(instance).to_not receive(:open_new_sells)
          expect(instance).to_not receive(:open_new_buys)
          process
        end

        context "the pending positions are expired" do
          let(:current_sell) { create(:pending_position, bias: Position::BIAS_BUY, position_type: position_type, expires_at: tick.date_time - 1.day) }
          let(:current_buy) { create(:pending_position, bias: Position::BIAS_SELL, position_type: position_type, expires_at: tick.date_time - 1.hour) }

          it "will attempt to expire any pending positions", :aggregate_failures do
            expect(instance).to receive(:expire_pending_sells).with(tick: tick, strategy: strategy)
            expect(instance).to receive(:expire_pending_buys).with(tick: tick, strategy: strategy)
            process
          end
        end

        context "the limit orders are triggerable" do
          let(:tick) { create(:tick, bid: 5.0, ask: 15.0 ) }

          it "will attempt to trigger any limit positions", :aggregate_failures do
            expect(instance).to receive(:trigger_pending_sells).with(tick: tick, strategy: strategy)
            expect(instance).to receive(:trigger_pending_buys).with(tick: tick, strategy: strategy)
            process
          end
        end
      end
    end
  end

  describe "#close_sells_for_profit" do
    subject(:close_sells_for_profit) { instance.close_sells_for_profit(tick: tick, strategy: strategy) }

    it "will attempt to close a sell for profit" do
      expect(position_closer).to receive(:close_position!)
      close_sells_for_profit
    end
  end

  describe "#close_buys_for_profit" do
    subject(:close_buys_for_profit) { instance.close_buys_for_profit(tick: tick, strategy: strategy) }

    it "will not attempt to close a buy for profit" do
      expect(position_closer).to receive(:close_position!)
      close_buys_for_profit
    end
  end

  describe "#close_sells_for_loss" do
    subject(:close_sells_for_loss) { instance.close_sells_for_loss(tick: tick, strategy: strategy) }

    it "will attempt to close a sell for loss" do
      expect(position_closer).to receive(:close_position!)
      close_sells_for_loss
    end
  end

  describe "#close_buys_for_loss" do
    subject(:close_buys_for_loss) { instance.close_buys_for_loss(tick: tick, strategy: strategy) }

    it "will attempt to close a buy for loss" do
      expect(position_closer).to receive(:close_position!)
      close_buys_for_loss
    end
  end

  describe "#open_new_sells" do
    subject(:open_new_sells) { instance.open_new_sells(tick: tick, strategy: strategy) }

    it "will not attempt to open any sells" do
      expect(strategy).to_not receive(:open_sell!)
      open_new_sells
    end

    context "we are eligible for sells" do
      let(:eligible_for_sells?) { true }

      it "will attempt to place a sell" do
        expect(strategy).to receive(:open_sell!).with(tick: tick)
        open_new_sells
      end
    end
  end

  describe "#open_new_buys" do
    subject(:open_new_buys) { instance.open_new_buys(tick: tick, strategy: strategy) }

    it "will not attempt to open any sells" do
      expect(strategy).to_not receive(:open_buy!)
      open_new_buys
    end

    context "we are eligible for sells" do
      let(:eligible_for_buys?) { true }

      it "will attempt to place a sell" do
        expect(strategy).to receive(:open_buy!).with(tick: tick)
        open_new_buys
      end
    end
  end

  describe "#expire_pending_sells" do
    subject(:expire_pending_sells) { instance.expire_pending_sells(tick: tick, strategy: strategy) }

    it "will attempt to expire a sell" do
      expect(position_closer).to receive(:expire_pending_position!).with(position: current_sell)
      expire_pending_sells
    end
  end

  describe "#expire_pending_buys" do
    subject(:expire_pending_buys) { instance.expire_pending_buys(tick: tick, strategy: strategy) }

    it "will attempt to expire a sell" do
      expect(position_closer).to receive(:expire_pending_position!).with(position: current_buy)
      expire_pending_buys
    end
  end

  describe "#trigger_pending_sells" do
    subject(:trigger_pending_sells) { instance.trigger_pending_sells(tick: tick, strategy: strategy) }

    it "will attempt to trigger a sell" do
      expect(position_opener).to receive(:trigger_pending_position).with(position: current_sell, open_price: tick.bid)
      trigger_pending_sells
    end
  end

  describe "#trigger_pending_buys" do
    subject(:trigger_pending_buys) { instance.trigger_pending_buys(tick: tick, strategy: strategy) }

    it "will attempt to trigger a buy" do
      expect(position_opener).to receive(:trigger_pending_position).with(position: current_buy, open_price: tick.ask)
      trigger_pending_buys
    end
  end
end