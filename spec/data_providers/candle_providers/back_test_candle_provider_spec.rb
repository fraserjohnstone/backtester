require "rails_helper"

describe DataProviders::CandleProviders::BackTestCandleProvider do
  let(:instance) { described_class.new(symbols: symbols, strategy: strategy) }
  let(:strategy) { instance_double(Strategies::BaseStrategy) }
  let(:symbols) { ["EURUSD"] }
  let(:returned_candles_m5) { [create(:candle, symbol: "EURUSD", timeframe: "m5")] }
  let(:returned_candles_m15) { [create(:candle, symbol: "EURUSD", timeframe: "m15")] }
  let(:returned_candles_h1) { [create(:candle, symbol: "EURUSD", timeframe: "h1")] }
  let(:returned_candles_h2) { [create(:candle, symbol: "EURUSD", timeframe: "h2")] }
  let(:returned_candles_h4) { [create(:candle, symbol: "EURUSD", timeframe: "h4")] }
  let(:tick_date_time) { DateTime.parse("2021-12-04 06:00") }

  before do
    allow(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "m5", open_time: anything).and_return(returned_candles_m5)
    allow(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "m15", open_time: anything).and_return(returned_candles_m15)
    allow(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h1", open_time: anything).and_return(returned_candles_h1)
    allow(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h2", open_time: anything).and_return(returned_candles_h2)
    allow(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h4", open_time: anything).and_return(returned_candles_h4)
    allow(strategy).to receive_message_chain(:log, :info)
  end

  describe "h4_candles" do
    subject(:h4_candles) { instance.h4_candles(tick_date_time: tick_date_time, symbol: "EURUSD") }

    it "will collect candles from the database" do
      expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h4", open_time: anything)
      h4_candles
    end

    context "there are already candles in memory" do
      before do
        instance.instance_variable_set(:@in_memory_h4_candles, {"EURUSD" => returned_candles_h4})
      end

      context "the tick time is before the last candle time" do
        let(:tick_date_time) { returned_candles_h4.last.close_time - 1.hour }

        it "will not gather more candles" do
          expect(Candle).to_not receive(:where)
          h4_candles
        end
      end

      context "the tick time is after the last candle time" do
        let(:tick_date_time) { returned_candles_h4.last.close_time + 1.hour }

        it "will not gather more candles" do
          expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h4", open_time: anything)
          h4_candles
        end
      end
    end
  end

  describe "h2_candles" do
    subject(:h2_candles) { instance.h2_candles(tick_date_time: tick_date_time, symbol: "EURUSD") }

    it "will collect candles from the database" do
      expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h2", open_time: anything)
      h2_candles
    end

    context "there are already candles in memory" do
      before do
        instance.instance_variable_set(:@in_memory_h2_candles, {"EURUSD" => returned_candles_h2})
      end

      context "the tick time is before the last candle time" do
        let(:tick_date_time) { returned_candles_h2.last.close_time - 1.hour }

        it "will not gather more candles" do
          expect(Candle).to_not receive(:where)
          h2_candles
        end
      end

      context "the tick time is after the last candle time" do
        let(:tick_date_time) { returned_candles_h2.last.close_time + 1.hour }

        it "will not gather more candles" do
          expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h2", open_time: anything)
          h2_candles
        end
      end
    end
  end
  
  describe "h1_candles" do
    subject(:h1_candles) { instance.h1_candles(tick_date_time: tick_date_time, symbol: "EURUSD") }

    it "will collect candles from the database" do
      expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h1", open_time: anything)
      h1_candles
    end

    context "there are already candles in memory" do
      before do
        instance.instance_variable_set(:@in_memory_h1_candles, {"EURUSD" => returned_candles_h1})
      end

      context "the tick time is before the last candle time" do
        let(:tick_date_time) { returned_candles_h1.last.close_time - 1.hour }

        it "will not gather more candles" do
          expect(Candle).to_not receive(:where)
          h1_candles
        end
      end

      context "the tick time is after the last candle time" do
        let(:tick_date_time) { returned_candles_h1.last.close_time + 1.hour }

        it "will not gather more candles" do
          expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "h1", open_time: anything)
          h1_candles
        end
      end
    end
  end


  describe "m15_candles" do
    subject(:m15_candles) { instance.m15_candles(tick_date_time: tick_date_time, symbol: "EURUSD") }

    it "will collect candles from the database" do
      expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "m15", open_time: anything)
      m15_candles
    end

    context "there are already candles in memory" do
      before do
        instance.instance_variable_set(:@in_memory_m15_candles, {"EURUSD" => returned_candles_m15})
      end

      context "the tick time is before the last candle time" do
        let(:tick_date_time) { returned_candles_m15.last.close_time - 1.hour }

        it "will not gather more candles" do
          expect(Candle).to_not receive(:where)
          m15_candles
        end
      end

      context "the tick time is after the last candle time" do
        let(:tick_date_time) { returned_candles_m15.last.close_time + 1.hour }

        it "will not gather more candles" do
          expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "m15", open_time: anything)
          m15_candles
        end
      end
    end
  end

  describe "m5_candles" do
    subject(:m5_candles) { instance.m5_candles(tick_date_time: tick_date_time, symbol: "EURUSD") }

    it "will collect candles from the database" do
      expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "m5", open_time: anything)
      m5_candles
    end

    context "there are already candles in memory" do
      before do
        instance.instance_variable_set(:@in_memory_m5_candles, {"EURUSD" => returned_candles_m5})
      end

      context "the tick time is before the last candle time" do
        let(:tick_date_time) { returned_candles_m5.last.close_time - 1.hour }

        it "will not gather more candles" do
          expect(Candle).to_not receive(:where)
          m5_candles
        end
      end

      context "the tick time is after the last candle time" do
        let(:tick_date_time) { returned_candles_m5.last.close_time + 1.hour }

        it "will not gather more candles" do
          expect(Candle).to receive(:where).with(symbol: "EURUSD", timeframe: "m5", open_time: anything)
          m5_candles
        end
      end
    end
  end
end