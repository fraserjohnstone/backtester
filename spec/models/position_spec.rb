require "rails_helper"

describe Position do
  let(:instance) do
    described_class.new(
      symbol: symbol,
      open_price: open_price,
      stop_loss_price: stop_loss_price,
      original_stop_loss_price: original_stop_loss_price,
      lot_size: lot_size,
      risk_as_money: risk_as_money,
      commission_as_money: commission_as_money,
      opened_at: opened_at,
      state: state,
      bias: bias,
      position_type: position_type
    )
  end
  let(:symbol) { "EURCHF" }
  let(:open_price) { 1.0453 }
  let(:stop_loss_price) { 1.0353 }
  let(:original_stop_loss_price) { stop_loss_price }
  let(:lot_size) { 0.76 }
  let(:risk_as_money) { 74.56 }
  let(:commission_as_money) { 1.2 }
  let(:opened_at) { 3.hours.ago }
  let(:state) { Position::STATE_OPEN }
  let(:bias) { Position::BIAS_BUY }
  let(:position_type) { Position::POSITION_TYPE_MARKET }

  describe "validations" do
    subject { instance }
    it { is_expected.to be_valid }

    context "the symbol is missing" do
      let(:symbol) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the open_price is missing" do
      let(:open_price) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the stop_loss_price is missing" do
      let(:stop_loss_price) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the original_stop_loss_price is missing" do
      let(:original_stop_loss_price) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the lot_size is missing" do
      let(:lot_size) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the risk_as_money is missing" do
      let(:risk_as_money) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the commission_as_money is missing" do
      let(:commission_as_money) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the opened_at is missing" do
      let(:opened_at) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the state is missing" do
      let(:state) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the bias is missing" do
      let(:bias) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the position_type is missing" do
      let(:position_type) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the state is not one ov the valid enum options" do
      let(:state) { :some_random_state }

      it "will raise an appropriate error" do
        expect { instance }.to raise_error(ArgumentError)
      end
    end

    context "the bias is not one ov the valid enum options" do
      let(:bias) { :some_random_bias }

      it "will raise an appropriate error" do
        expect { instance }.to raise_error(ArgumentError)
      end
    end

    context "the position_type is not one ov the valid enum options" do
      let(:position_type) { :some_random_bias }

      it "will raise an appropriate error" do
        expect { instance }.to raise_error(ArgumentError)
      end
    end
  end

  describe "defaults" do
    describe "gross_profit" do
      subject(:gross_profit) { instance.gross_profit }
      it { is_expected.to eq 0.0 }
    end

    describe "spread_history" do
      subject(:spread_history) { instance.spread_history }
      it { is_expected.to eq [] }
    end
  end

  describe "#open?" do
    subject(:open?) { instance.open? }

    it { is_expected.to be true }

    context "the state is pending" do
      let(:state) { Position::STATE_PENDING }
      let(:position_type) { Position::POSITION_TYPE_STOP }

      it { is_expected.to be false }
    end
  end

  describe "#pending?" do
    subject(:pending?) { instance.pending? }

    it { is_expected.to be false }

    context "the state is pending" do
      let(:state) { Position::STATE_PENDING }
      let(:position_type) { Position::POSITION_TYPE_STOP }

      it { is_expected.to be true }
    end
  end

  describe "#abs_current_change_in_price" do
    subject(:abs_current_change_in_price) { instance.abs_current_change_in_price(tick: tick) }

    let(:open_price) { 10 }
    let(:tick) { create(:tick, ask: tick_ask, bid: tick_bid) }
    let(:tick_ask) { 15 }
    let(:tick_bid) { 14 }

    context "the tick prices are higher than the position open price" do
      context "the bias of the position is sell" do
        let(:bias) { Position::BIAS_SELL }

        it { is_expected.to eq 5 }
      end

      context "the bias of the position is buy" do
        let(:bias) { Position::BIAS_BUY }

        it { is_expected.to eq 4 }
      end
    end

    context "the tick prices are lower than the position open price" do
      let(:tick_ask) { 7 }
      let(:tick_bid) { 2 }

      context "the bias of the position is sell" do
        let(:bias) { Position::BIAS_SELL }

        it { is_expected.to eq 3 }
      end

      context "the bias of the position is buy" do
        let(:bias) { Position::BIAS_BUY }

        it { is_expected.to eq 8 }
      end
    end
  end

  describe "#abs_change_pct_of_stop" do
    subject(:abs_change_pct_of_stop) { instance.abs_change_pct_of_stop(tick: tick) }

    let(:tick) { create(:tick, ask: tick_ask, bid: tick_bid) }
    let(:tick_ask) { 130 }
    let(:tick_bid) { 120 }
    let(:open_price) { 100 }
    let(:stop_loss_price) { 80 }
    let(:take_profit_price) { 180 }

    context "the tick prices are higher than the position open price" do
      context "the bias of the position is sell" do
        let(:bias) { Position::BIAS_SELL }

        it { is_expected.to eq 1.5 }
      end

      context "the bias of the position is buy" do
        let(:bias) { Position::BIAS_BUY }

        it { is_expected.to eq 1.0 }
      end
    end

    context "the tick prices are lower than the position open price" do
      let(:tick_ask) { 85 }
      let(:tick_bid) { 75 }

      context "the bias of the position is sell" do
        let(:bias) { Position::BIAS_SELL }

        it { is_expected.to eq 0.75 }
      end

      context "the bias of the position is buy" do
        let(:bias) { Position::BIAS_BUY }

        it { is_expected.to eq 1.25 }
      end
    end
  end

  describe "#abs_profit" do
    subject(:abs_profit) { instance.abs_profit(tick: tick) }

    let(:tick) { create(:tick) }
    let(:risk_as_money) { 60.0 }
    let(:abs_change_pct) { 1.2 }
    let(:expected) { 72.0 }

    before do
      allow(instance).to receive(:abs_change_pct_of_stop).with(tick: tick).and_return(abs_change_pct)
    end

    it { is_expected.to eq expected }
  end

  describe "#current_gross_profit" do
    subject(:current_gross_profit) { instance.current_gross_profit(tick: tick) }

    let(:open_price) { 100 }
    let(:bias) { Position::BIAS_SELL }

    let(:tick) { create(:tick, ask: tick_ask, bid: tick_bid) }
    let(:tick_ask) { 80 }
    let(:tick_bid) { 75 }
    let(:abs_profit) { 25.0 }
    let(:expected) { abs_profit }

    before do
      allow(instance).to receive(:abs_profit).with(tick: tick).and_return(abs_profit)
    end

    it { is_expected.to eq expected }

    context "the tick ask price is higher than the open" do
      let(:tick_ask) { 120 }
      let(:expected) { -abs_profit }

      it { is_expected.to eq expected }
    end

    describe "the bias is buy" do
      let(:bias) { Position::BIAS_BUY }
      let(:tick_ask) { 115 }
      let(:tick_bid) { 120 }

      it { is_expected.to eq expected }

      context "the tick bid price is lower than the open" do
        let(:tick_bid) { 80 }
        let(:expected) { -abs_profit }

        it { is_expected.to eq expected }
      end
    end
  end

  describe "#net_profit?" do
    subject(:net_profit) { instance.net_profit }

    let(:gross_profit) { 50.0 }
    let(:commission_as_money) { 2 }
    let(:expected) { 48 }

    before do
      allow(instance).to receive(:gross_profit).and_return(gross_profit)
    end

    it { is_expected.to eq expected }

    context "the gross_profit is negative" do
      let(:gross_profit) { -10.0 }
      let(:commission_as_money) { 2 }
      let(:expected) { -12.0 }

      it { is_expected.to be expected }
    end

    context "the gross_profit is very low" do
      let(:gross_profit) { 1.0 }
      let(:commission_as_money) { 2 }
      let(:expected) { -1.0 }

      it { is_expected.to be expected }
    end
  end
end