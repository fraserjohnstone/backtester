require "rails_helper"

describe Indicators do
  let(:instance) { described_class.new }
  let(:input_candles) { 2.times.map { build(:candle) } }
  let(:subset_candles) { input_candles.map(&:to_h) }

  describe "#atr" do
    subject(:atr) { instance.atr(candles: input_candles, period: period) }

    let(:period) { 14 }
    let(:atr_response) { [double(atr: 1), double(atr: 2)] }
    let(:expected) { atr_response.reverse }

    before do
      allow(TechnicalAnalysis::Atr).to receive(:calculate).with(anything, period: period).and_return(atr_response)
    end

    it { is_expected.to eq expected }
  end

  describe "#ema" do
    subject(:ema) { instance.ema(candles: input_candles, period: period) }

    let(:period) { 14 }
    let(:ema_response) { [double(ema: 1), double(ema: 2), double(ema: 3)] }
    let(:expected) { ema_response.reverse }

    before do
      allow(TechnicalAnalysis::Ema).to receive(:calculate).with(subset_candles, period: period, price_key: :close).and_return(ema_response)
    end

    it { is_expected.to eq expected }
  end

  describe "#sma" do
    subject(:sma) { instance.sma(candles: input_candles, period: period) }

    let(:period) { 14 }
    let(:sma_response) { [double(sma: 1), double(sma: 2), double(sma: 3)] }
    let(:expected) { sma_response.reverse }

    before do
      allow(TechnicalAnalysis::Sma).to receive(:calculate).with(subset_candles, period: period, price_key: :close).and_return(sma_response)
    end

    it { is_expected.to eq expected }
  end

  describe "#bb" do
    subject(:bb) { instance.bb(candles: input_candles, period: period) }

    let(:period) { 14 }
    let(:bb_response) { [double(upper_band: 1, lower_band: 1), double(upper_band: 2, lower_band: 2), double(upper_band: 3, lower_band: 3)] }
    let(:expected) { bb_response.reverse }

    before do
      allow(TechnicalAnalysis::Bb).to receive(:calculate).with(subset_candles, period: period, price_key: :close).and_return(bb_response)
    end

    it { is_expected.to eq expected }
  end
end