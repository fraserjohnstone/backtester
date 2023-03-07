require "rails_helper"

describe Positions::PositionTrackers::BackTestPositionTracker do
  let(:instance) { described_class.new(strategy: strategy) }
  let(:strategy) { instance_double(Strategies::BaseStrategy) }
  let(:sell_position) { create(:position, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_MARKET) }
  let(:buy_position) { create(:position, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET) }

  before do
    allow(strategy).to receive_message_chain(:log, :info)
  end

  describe "#track_sell_position" do
    subject(:track_sell_position) { instance.track_sell_position(position: sell_position) }

    it "will set the open sell position" do
      track_sell_position
      expect(instance.instance_variable_get(:@open_sells)[sell_position.symbol]).to be sell_position
    end
  end

  describe "#track_buy_position" do
    subject(:track_buy_position) { instance.track_buy_position(position: buy_position) }

    it "will set the open buy position" do
      track_buy_position
      expect(instance.instance_variable_get(:@open_buys)[buy_position.symbol]).to be buy_position
    end
  end

  describe "#release_sell_position" do
    subject(:release_sell_position) { instance.release_sell_position(position: sell_position) }

    before do
      instance.instance_variable_set(:@open_sells, {sell_position.symbol => sell_position})
    end

    it "will clear the open sell position" do
      release_sell_position
      expect(instance.instance_variable_get(:@open_sells)[sell_position.symbol]).to be nil
    end
  end

  describe "#release_buy_position" do
    subject(:release_buy_position) { instance.release_buy_position(position: buy_position) }

    before do
      instance.instance_variable_set(:@open_buys, {buy_position.symbol => buy_position})
    end

    it "will clear the open buy position" do
      release_buy_position
      expect(instance.instance_variable_get(:@open_buys)[buy_position.symbol]).to be nil
    end
  end

  describe "#already_selling?" do
    subject(:already_selling?) { instance.already_selling?(symbol: sell_position.symbol) }

    it { is_expected.to be false }

    context "there is already an open sell" do
      before do
        instance.instance_variable_set(:@open_sells, {sell_position.symbol => sell_position})
      end

      it { is_expected.to be true }
    end
  end

  describe "#already_buying?" do
    subject(:already_buying?) { instance.already_buying?(symbol: buy_position.symbol) }

    it { is_expected.to be false }

    context "there is already an open buy" do
      before do
        instance.instance_variable_set(:@open_buys, {buy_position.symbol => buy_position})
      end

      it { is_expected.to be true }
    end
  end

  describe "#current_sell" do
    subject(:current_sell) { instance.current_sell(symbol: sell_position.symbol) }

    it { is_expected.to be nil }

    context "there is already an open sell" do
      before do
        instance.instance_variable_set(:@open_sells, {sell_position.symbol => sell_position})
      end

      it { is_expected.to be sell_position }
    end
  end

  describe "#current_buy" do
    subject(:current_buy) { instance.current_buy(symbol: buy_position.symbol) }

    it { is_expected.to be nil }

    context "there is already an open buy" do
      before do
        instance.instance_variable_set(:@open_buys, {buy_position.symbol => buy_position})
      end

      it { is_expected.to be buy_position }
    end
  end
end