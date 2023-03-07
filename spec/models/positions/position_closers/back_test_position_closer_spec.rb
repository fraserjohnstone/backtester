require 'rails_helper'

describe Positions::PositionClosers::BackTestPositionCloser do
  let(:instance) { described_class.new(strategy: strategy) }

  let(:strategy) do
    double(
      position_tracker: position_tracker,
      account: account
    )
  end
  let(:account) { create(:back_test_account, back_test: back_test) }
  let(:back_test) { create(:back_test) }
  let(:position_tracker) { instance_double(Positions::PositionTrackers::BackTestPositionTracker, release_sell_position: nil, release_buy_position: nil) }
  let(:position) do
    create(
      :open_position,
      bias: bias,
      position_type: position_type
    )
  end
  let(:tick) do
    create(
      :tick,
      symbol: position.symbol,
      bid: bid,
      ask: ask
    )
  end
  let(:bias) { nil }
  let(:position_type) { Position::POSITION_TYPE_MARKET }
  let(:ask) { 1.5 }
  let(:bid) { 1.2 }
  let(:current_gross_profit) { 52.0 }
  let(:net_profit) { 49.2 }
  let(:bias) { Position::BIAS_SELL }

  before do
    allow(position).to receive(:current_gross_profit).with(tick: tick).and_return(current_gross_profit)
    allow(position).to receive(:net_profit).and_return(net_profit)
    allow(strategy).to receive_message_chain(:log, :info)
  end

  describe "#close_position!" do
    subject(:close_position!) { instance.close_position!(position: position, tick: tick) }

    it "will change the position closed_at timestamp" do
      expect { close_position! }.to change { position.closed_at }.from(nil).to(tick.date_time)
    end

    it "will change the position state" do
      expect { close_position! }.to change { position.state }.from(Position::STATE_OPEN).to(Position::STATE_CLOSED)
    end

    it "will change the position gross profit" do
      expect { close_position! }.to change { position.gross_profit }.from(0.0).to(current_gross_profit)
    end

    it "will stop tracking the position" do
      expect(position_tracker).to receive(:release_sell_position).with(position: position)
      close_position!
    end

    it "will change the account balance" do
      expect { close_position! }.to change { account.current_balance }.from(account.starting_balance).to(account.starting_balance + net_profit)
    end

    context "the net_profit is negative" do
      let(:net_profit) { -22.35 }

      it "will change the account balance" do
        expect { close_position! }.to change { account.current_balance }.from(account.starting_balance).to(account.starting_balance + net_profit)
      end
    end

    it "will change the close price to the ask price of the tick" do
      expect { close_position! }.to change { position.close_price }.from(nil).to(ask)
    end

    context "closing a buy" do
      let(:bias) { Position::BIAS_BUY }

      it "will change the close price to the bid price of the tick" do
        expect { close_position! }.to change { position.close_price }.from(nil).to(bid)
      end

      it "will stop tracking the position" do
        expect(position_tracker).to receive(:release_buy_position).with(position: position)
        close_position!
      end
    end
  end

  describe "#expire_pending_position!" do
    subject(:expire_pending_position!) { instance.expire_pending_position!(position: position) }

    let(:position) do
      create(
        :pending_position,
        bias: bias,
        position_type: position_type
      )
    end
    let(:position_type) { Position::POSITION_TYPE_STOP }

    it "destroys the position" do
      expect { expire_pending_position! }.to change { Position.count }.by(-1)
    end

    context "the position is a pending sell" do
      let(:bias) { Position::BIAS_SELL }

      it "will stop tracking the position" do
        expect(position_tracker).to receive(:release_sell_position).with(position: position)
        expire_pending_position!
      end
    end

    context "the position is a pending sell" do
      let(:bias) { Position::BIAS_BUY }

      it "will stop tracking the position" do
        expect(position_tracker).to receive(:release_buy_position).with(position: position)
        expire_pending_position!
      end
    end
  end
end
