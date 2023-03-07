require "rails_helper"

describe Candle do
  let(:instance) do
    described_class.new(
      uuid: uuid,
      symbol: symbol,
      timeframe: timeframe,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      open_time: open_time
    )
  end
  let(:symbol) { "EURUSD" }
  let(:timeframe) { "h1" }
  let(:open) { 1.0 }
  let(:high) { 1.1 }
  let(:low) { 0.9 }
  let(:close) { 0.9 }
  let(:volume) { 12345.3 }
  let(:open_time) { 7.days.ago }
  let(:uuid) { SecureRandom.uuid }

  describe "validations" do
    subject { instance }
    it { is_expected.to be_valid }

    context "the uuid is missing" do
      let(:uuid) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the timeframe is missing" do
      let(:timeframe) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the symbol is missing" do
      let(:symbol) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the open is missing" do
      let(:open) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the high is missing" do
      let(:high) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the low is missing" do
      let(:low) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the open is missing" do
      let(:open) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the close is missing" do
      let(:close) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the open_time is missing" do
      let(:open_time) { nil }
      it { is_expected.to_not be_valid }
    end
  end

  describe "#close_time" do
    subject(:close_time) { instance.close_time }

    context "timeframe is m5" do
      let(:timeframe) { "m5" }
      let(:expected_close_time) { open_time + 5.minutes }

      it { is_expected.to be_within(1.second).of(expected_close_time) }
    end

    context "timeframe is m15" do
      let(:timeframe) { "m15" }
      let(:expected_close_time) { open_time + 15.minutes }

      it { is_expected.to be_within(1.second).of(expected_close_time) }
    end

    context "timeframe is h1" do
      let(:timeframe) { "h1" }
      let(:expected_close_time) { open_time + 1.hour }

      it { is_expected.to be_within(1.second).of(expected_close_time) }
    end

    context "timeframe is h2" do
      let(:timeframe) { "h2" }
      let(:expected_close_time) { open_time + 2.hours }

      it { is_expected.to be_within(1.second).of(expected_close_time) }
    end

    context "timeframe is h4" do
      let(:timeframe) { "h4" }
      let(:expected_close_time) { open_time + 4.hours }

      it { is_expected.to be_within(1.second).of(expected_close_time) }
    end
  end

  describe "#to_h" do
    subject(:to_h) { instance.to_h }

    let(:expected_hash) do
      {
        open: instance.open,
        high: instance.high,
        low: instance.low,
        close: instance.close,
        date_time: instance.open_time,
        volume: instance.volume,
        symbol: instance.symbol,
        timeframe: instance.timeframe
      }
    end

    it { is_expected.to eq expected_hash }
  end

  describe "#bearish?" do
    subject(:bearish?) { instance.bearish? }

    context "the candle open is higher than the candle close" do
      let(:open) { 1.01 }
      let(:close) { 1.001 }

      it { is_expected.to be true }
    end

    context "the candle open is lower than the candle close" do
      let(:open) { 1.03 }
      let(:close) { 1.078 }

      it { is_expected.to be false }
    end
  end

  describe "#bullish?" do
    subject(:bullish?) { instance.bullish? }

    context "the candle open is higher than the candle close" do
      let(:open) { 1.01 }
      let(:close) { 1.001 }

      it { is_expected.to be false }
    end

    context "the candle open is lower than the candle close" do
      let(:open) { 1.03 }
      let(:close) { 1.078 }

      it { is_expected.to be true }
    end
  end

  describe "#body" do
    subject(:body) { instance.body }

    context "the candle in bearish" do
      let(:open) { 1.2 }
      let(:close) { 1.1 }

      it { is_expected.to be_within(0.00001).of(0.1) }
    end

    context "the candle is bullish" do
      let(:open) { 1.03 }
      let(:close) { 1.06 }

      it { is_expected.to be_within(0.00001).of(0.03) }
    end
  end

  describe "#range" do
    subject(:range) { instance.range }

    context "the candle is bearish" do
      let(:high) { 2.9 }
      let(:low) { 0.5 }
      let(:open) { 1.4 }
      let(:close) { 1.1 }

      it { is_expected.to be_within(0.00001).of(2.4) }
    end

    context "the candle is bullish" do
      let(:high) { 1.8 }
      let(:low) { 0.1 }
      let(:open) { 1.1 }
      let(:close) { 1.6 }

      it { is_expected.to be_within(0.00001).of(1.7) }
    end
  end

  describe "#top_wick" do
    subject(:top_wick) { instance.top_wick }

    context "the candle is bearish" do
      let(:high) { 2.4 }
      let(:low) { 0.2 }
      let(:open) { 1.9 }
      let(:close) { 1.2 }

      it { is_expected.to be_within(0.00001).of(0.5) }
    end

    context "the candle is bullish" do
      let(:high) { 2.9 }
      let(:low) { 0.5 }
      let(:open) { 0.7 }
      let(:close) { 1.2 }

      it { is_expected.to be_within(0.00001).of(1.7) }
    end
  end

  describe "#bottom_wick" do
    subject(:bottom_wick) { instance.bottom_wick }

    context "the candle is bearish" do
      let(:high) { 2.4 }
      let(:low) { 0.2 }
      let(:open) { 1.9 }
      let(:close) { 1.2 }

      it { is_expected.to be_within(0.00001).of(1.0) }
    end

    context "the candle is bullish" do
      let(:high) { 2.9 }
      let(:low) { 0.5 }
      let(:open) { 0.7 }
      let(:close) { 1.2 }

      it { is_expected.to be_within(0.00001).of(0.2) }
    end
  end

  describe "#percent_of_body" do
    subject(:percent_of_body) { instance.percent_of_body(pct: pct) }

    let(:pct) { 0.5 }

    context "the candle is bearish" do
      let(:high) { 8.0 }
      let(:low) { 0.2 }
      let(:open) { 5.0 }
      let(:close) { 1.0 }

      let(:expected) { 3.0 }

      it { is_expected.to be_within(0.00001).of(expected) }

      context "with a different argument < 0.5" do
        let(:pct) { 0.4 }
        let(:expected) { 2.6 }

        it { is_expected.to be_within(0.00001).of(expected) }
      end

      context "with a different argument > 0.5" do
        let(:pct) { 0.85 }
        let(:expected) { 4.4 }

        it { is_expected.to be_within(0.00001).of(expected) }
      end
    end

    context "the candle is bullish" do
      let(:high) { 8.0 }
      let(:low) { 0.2 }
      let(:open) { 2.0 }
      let(:close) { 3.0 }

      let(:expected) { 2.5 }

      it { is_expected.to be_within(0.00001).of(expected) }

      context "with a different argument < 0.5" do
        let(:pct) { 0.356 }
        let(:expected) { 2.356 }

        it { is_expected.to be_within(0.00001).of(expected) }
      end

      context "with a different argument > 0.5" do
        let(:pct) { 0.666 }
        let(:expected) { 2.666 }

        it { is_expected.to be_within(0.00001).of(expected) }
      end
    end
  end

  describe "#bearish_pin_bar?" do
    subject(:bearish_pin_bar?) { instance.bearish_pin_bar? }

    context "the candle is a bearish pin bar" do
      let(:open) { 1.0 }
      let(:close) { 0.9 }
      let(:low) { 0.7 }
      let(:high) { 2.0 }

      it { is_expected.to be true }
    end

    context "the candle is not a bearish pin_bar" do
      let(:open) { 1.0 }
      let(:close) { 0.9 }
      let(:low) { 0.1 }
      let(:high) { 1.1 }

      it { is_expected.to be false }
    end
  end

  describe "#bullish_pin_bar?" do
    subject(:bullish_pin_bar?) { instance.bullish_pin_bar? }

    context "the candle is a bullish pin bar" do
      let(:open) { 1.0 }
      let(:close) { 1.1 }
      let(:low) { 0.1 }
      let(:high) { 1.2 }

      it { is_expected.to be true }
    end

    context "the candle is not a bullish pin_bar" do
      let(:open) { 1.0 }
      let(:close) { 0.9 }
      let(:low) { 0.8 }
      let(:high) { 1.1 }

      it { is_expected.to be false }
    end
  end
end