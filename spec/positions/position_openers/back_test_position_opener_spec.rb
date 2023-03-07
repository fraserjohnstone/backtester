require "rails_helper"

describe Positions::PositionOpeners::BackTestPositionOpener do
  let(:instance) { described_class.new(strategy: strategy) }
  let(:strategy) do
    double(
      take_profit?: take_profit?,
      stop_loss_distance: stop_loss_distance,
      profit_to_loss_ratio: profit_to_loss_ratio,
      position_tracker: position_tracker,
      back_test: back_test,
      account: back_test_account,
      pending_position_expiry_period: 2.hours
    )
  end
  let(:back_test) { create(:back_test, back_test_account: back_test_account) }
  let(:back_test_account) { create(:back_test_account) }
  let(:position_tracker) { instance_double(Positions::PositionTrackers::BackTestPositionTracker, track_buy_position: nil, track_sell_position: nil) }

  let(:take_profit?) { true }
  let(:stop_loss_distance) { 0.001 }
  let(:profit_to_loss_ratio) { 2 }

  before do
    allow(strategy).to receive_message_chain(:log, :info)
  end

  describe "position creation" do
    let(:tick) { create(:tick) }

    describe "#open_market_buy" do
      subject(:open_market_buy) { instance.open_market_buy(tick: tick) }

      it "will add an open position to the database" do
        expect { open_market_buy }.to change { Position.buys.open.count }.from(0).to(1)
      end

      it "will track the position" do
        expect(position_tracker).to receive(:track_buy_position)
        open_market_buy
      end

      it "will recognise the symbol as forex" do
        expect(Symbols::FOREX).to receive(:include?).with(tick.symbol).and_return(true)
        open_market_buy
      end

      context "the symbol is a US stock" do
        let(:tick) { create(:tick, symbol: "TSLA") }
        let(:stop_loss_distance) { 0.021 }

        it "will recognise the symbol as us stock" do
          expect(Symbols::US_STOCKS).to receive(:include?).with(tick.symbol).and_return(true)
          open_market_buy
        end
      end

      describe "position fields" do
        before do
          open_market_buy
        end

        it "will be associated with the correct back test" do
          expect(Position.buys.last.back_test.id).to be back_test.id
        end

        it "will have an open price higher than the stop loss price" do
          expect(Position.buys.last.open_price > Position.buys.last.stop_loss_price).to be true
        end

        it "will have an open price lower than the take profit price" do
          expect(Position.buys.last.open_price < Position.buys.last.take_profit_price).to be true
        end

        it "will have the correct bias" do
          expect(Position.buys.last.bias).to eq Position::BIAS_BUY
        end

        it "will have the correct position type" do
          expect(Position.buys.last.position_type).to eq Position::POSITION_TYPE_MARKET
        end

        it "will have the correct state" do
          expect(Position.buys.last.state).to eq Position::STATE_OPEN
        end

        context "the back test specifies that no take profit should be set" do
          let(:take_profit?) { false }

          it "the take profit price will be nil" do
            expect(Position.buys.last.take_profit_price).to be nil
          end
        end
      end
    end

    describe "#open_market_sell" do
      subject(:open_market_sell) { instance.open_market_sell(tick: tick) }

      it "will add an open sell position to the database" do
        expect { open_market_sell }.to change { Position.sells.open.count }.from(0).to(1)
      end

      it "will track the position" do
        expect(position_tracker).to receive(:track_sell_position)
        open_market_sell
      end

      describe "position fields" do
        before do
          open_market_sell
        end

        it "will be associated with the correct back test" do
          expect(Position.sells.open.last.back_test.id).to be back_test.id
        end

        it "will have an open price lower than the stop loss price" do
          expect(Position.sells.open.last.open_price < Position.sells.open.last.stop_loss_price).to be true
        end

        it "will have an open price higher than the take profit price" do
          expect(Position.sells.open.last.open_price > Position.sells.open.last.take_profit_price).to be true
        end

        it "will have the correct bias" do
          expect(Position.sells.open.last.bias).to eq Position::BIAS_SELL
        end

        it "will have the correct position type" do
          expect(Position.sells.open.last.position_type).to eq Position::POSITION_TYPE_MARKET
        end

        it "will have the correct state" do
          expect(Position.sells.open.last.state).to eq Position::STATE_OPEN
        end

        context "the back test specifies that no take profit should be set" do
          let(:take_profit?) { false }

          it "the take profit price will be nil" do
            expect(Position.sells.open.last.take_profit_price).to be nil
          end
        end
      end
    end

    describe "#open_limit_buy" do
      subject(:open_limit_buy) { instance.open_limit_buy(tick: tick, open_price: open_price) }

      let(:open_price) { tick.ask - 0.0002 }

      it "will add a pending buy position to the database" do
        expect { open_limit_buy }.to change { Position.buys.pending.count }.from(0).to(1)
      end

      it "will track the position" do
        expect(position_tracker).to receive(:track_buy_position)
        open_limit_buy
      end

      describe "position fields" do
        before do
          open_limit_buy
        end

        it "will have the correct open price" do
          expect(Position.buys.pending.last.open_price.round(4).to_s).to eq open_price.round(4).to_s
        end

        it "will have an open price lower than the ask price" do
          expect(Position.buys.pending.last.open_price < tick.ask).to be true
        end

        it "will be associated with the correct back test" do
          expect(Position.buys.pending.last.back_test.id).to be back_test.id
        end

        it "will have an open price higher than the stop loss price" do
          expect(Position.buys.pending.last.open_price > Position.buys.pending.last.stop_loss_price).to be true
        end

        it "will have an open price lower than the take profit price" do
          expect(Position.buys.pending.last.open_price < Position.buys.pending.last.take_profit_price).to be true
        end

        it "will have the correct bias" do
          expect(Position.buys.pending.last.bias).to eq Position::BIAS_BUY
        end

        it "will have the correct position type" do
          expect(Position.buys.pending.last.position_type).to eq Position::POSITION_TYPE_LIMIT
        end

        it "will have the correct state" do
          expect(Position.buys.pending.last.state).to eq Position::STATE_PENDING
        end

        context "the back test specifies that no take profit should be set" do
          let(:take_profit?) { false }

          it "the take profit price will be nil" do
            expect(Position.buys.pending.last.take_profit_price).to be nil
          end
        end
      end
    end

    describe "#open_limit_sell" do
      subject(:open_limit_sell) { instance.open_limit_sell(tick: tick, open_price: open_price) }

      let(:open_price) { tick.bid + 0.0002 }

      it "will add a pending buy position to the database" do
        expect { open_limit_sell }.to change { Position.sells.pending.count }.from(0).to(1)
      end

      it "will track the position" do
        expect(position_tracker).to receive(:track_sell_position)
        open_limit_sell
      end

      describe "position fields" do
        before do
          open_limit_sell
        end

        it "will have the correct open price" do
          expect(Position.sells.pending.last.open_price.round(4).to_s).to eq open_price.round(4).to_s
        end

        it "will have an open price higher than the bid price" do
          expect(Position.sells.pending.last.open_price > tick.bid).to be true
        end

        it "will be associated with the correct back test" do
          expect(Position.sells.pending.last.back_test.id).to be back_test.id
        end

        it "will have an open price lower than the stop loss price" do
          expect(Position.sells.pending.last.open_price < Position.sells.pending.last.stop_loss_price).to be true
        end

        it "will have an open price higher than the take profit price" do
          expect(Position.sells.pending.last.open_price > Position.sells.pending.last.take_profit_price).to be true
        end

        it "will have the correct bias" do
          expect(Position.sells.pending.last.bias).to eq Position::BIAS_SELL
        end

        it "will have the correct position type" do
          expect(Position.sells.pending.last.position_type).to eq Position::POSITION_TYPE_LIMIT
        end

        it "will have the correct state" do
          expect(Position.sells.pending.last.state).to eq Position::STATE_PENDING
        end

        context "the back test specifies that no take profit should be set" do
          let(:take_profit?) { false }

          it "the take profit price will be nil" do
            expect(Position.sells.pending.last.take_profit_price).to be nil
          end
        end
      end
    end

    describe "#open_stop_buy" do
      subject(:open_stop_buy) { instance.open_stop_buy(tick: tick, open_price: open_price) }

      let(:open_price) { tick.ask + 0.0002 }

      it "will add a pending buy position to the database" do
        expect { open_stop_buy }.to change { Position.buys.pending.count }.from(0).to(1)
      end

      it "will track the position" do
        expect(position_tracker).to receive(:track_buy_position)
        open_stop_buy
      end

      describe "position fields" do
        before do
          open_stop_buy
        end

        it "will have the correct open price" do
          expect(Position.buys.pending.last.open_price.round(4).to_s).to eq open_price.round(4).to_s
        end

        it "will have an open price higher than the ask price" do
          expect(Position.buys.pending.last.open_price > tick.ask).to be true
        end

        it "will be associated with the correct back test" do
          expect(Position.buys.pending.last.back_test.id).to be back_test.id
        end

        it "will have an open price higher than the stop loss price" do
          expect(Position.buys.pending.last.open_price > Position.buys.pending.last.stop_loss_price).to be true
        end

        it "will have an open price lower than the take profit price" do
          expect(Position.buys.pending.last.open_price < Position.buys.pending.last.take_profit_price).to be true
        end

        it "will have the correct bias" do
          expect(Position.buys.pending.last.bias).to eq Position::BIAS_BUY
        end

        it "will have the correct position type" do
          expect(Position.buys.pending.last.position_type).to eq Position::POSITION_TYPE_STOP
        end

        it "will have the correct state" do
          expect(Position.buys.pending.last.state).to eq Position::STATE_PENDING
        end

        context "the back test specifies that no take profit should be set" do
          let(:take_profit?) { false }

          it "the take profit price will be nil" do
            expect(Position.buys.pending.last.take_profit_price).to be nil
          end
        end
      end
    end

    describe "#open_stop_sell" do
      subject(:open_stop_sell) { instance.open_stop_sell(tick: tick, open_price: open_price) }

      let(:open_price) { tick.ask - 0.0002 }

      it "will add a pending buy position to the database" do
        expect { open_stop_sell }.to change { Position.sells.pending.count }.from(0).to(1)
      end

      it "will track the position" do
        expect(position_tracker).to receive(:track_sell_position)
        open_stop_sell
      end

      describe "position fields" do
        before do
          open_stop_sell
        end

        it "will have the correct open price" do
          expect(Position.sells.pending.last.open_price.round(4).to_s).to eq open_price.round(4).to_s
        end

        it "will have an open price lower than the bid price" do
          expect(Position.sells.pending.last.open_price < tick.bid).to be true
        end

        it "will be associated with the correct back test" do
          expect(Position.sells.pending.last.back_test.id).to be back_test.id
        end

        it "will have an open price lower than the stop loss price" do
          expect(Position.sells.pending.last.open_price < Position.sells.pending.last.stop_loss_price).to be true
        end

        it "will have an open price higher than the take profit price" do
          expect(Position.sells.pending.last.open_price > Position.sells.pending.last.take_profit_price).to be true
        end

        it "will have the correct bias" do
          expect(Position.sells.pending.last.bias).to eq Position::BIAS_SELL
        end

        it "will have the correct position type" do
          expect(Position.sells.pending.last.position_type).to eq Position::POSITION_TYPE_STOP
        end

        it "will have the correct state" do
          expect(Position.sells.pending.last.state).to eq Position::STATE_PENDING
        end

        context "the back test specifies that no take profit should be set" do
          let(:take_profit?) { false }

          it "the take profit price will be nil" do
            expect(Position.sells.pending.last.take_profit_price).to be nil
          end
        end
      end

      describe "#trigger_pending_position" do
        subject(:trigger_pending_position) { instance.trigger_pending_position(position: position, open_price: open_price) }

        let(:position) { nil }
        let(:pending_sell_position) do
          create(
            :pending_position,
            bias: Position::BIAS_SELL,
            position_type: Position::POSITION_TYPE_LIMIT,
            open_price: 1.0,
          )
        end
        let(:pending_buy_position) do
          create(
            :pending_position,
            bias: Position::BIAS_BUY,
            position_type: Position::POSITION_TYPE_LIMIT,
            open_price: 1.0,
            )
        end
        let(:open_price) { nil }

        context "the position type is a limit sell", :aggregate_failures do
          let(:position) { pending_sell_position }
          let(:open_price) { tick.bid }

          it "will update the state" do
            expect { trigger_pending_position }.to change { pending_sell_position.state }.from(Position::STATE_PENDING).to(Position::STATE_OPEN)
          end

          it "will update the open_price" do
            expect { trigger_pending_position }.to change { pending_sell_position.open_price }.from(anything).to(open_price)
          end
        end

        context "the position type is a limit buy", :aggregate_failures do
          let(:position) { pending_buy_position }
          let(:open_price) { tick.ask }

          it "will update the state" do
            expect { trigger_pending_position }.to change { pending_buy_position.state }.from(Position::STATE_PENDING).to(Position::STATE_OPEN)
          end

          it "will update the open_price" do
            expect { trigger_pending_position }.to change { pending_buy_position.open_price }.from(anything).to(open_price)
          end
        end
      end
    end
  end
end