require "rails_helper"

describe Strategies::BaseStrategy do
  describe ".run!" do
    subject(:run!) { described_class.run! }

    let(:json_file_contents) do
      {
        base_strategy: {
          mode: mode,
          symbols: symbols,
          back_testing: {
            start_date: start_date,
            end_date: end_date,
            risk_pct: risk_pct,
            commission_pct: commission_pct
          }
        }
      }.to_json
    end
    let(:mode) { Modules::Configuration::Configurable::MODE_BACK_TEST }
    let(:symbols) { ["EURUSD"] }
    let(:start_date) { "2012-03-02" }
    let(:end_date) { "2015-02-07" }
    let(:risk_pct) { "0.34" }
    let(:commission_pct) { "4.1" }
    let(:mock_logger) { instance_double(Logger) }

    let(:tick_provider) { nil }
    let(:candle_provider) { nil }
    let(:back_test) { nil }
    let(:account) { nil }
    let(:position_opener) { nil }
    let(:position_closer) { nil }
    let(:position_tracker) { nil }
    let(:tick_processor) { instance_double(TickProcessor) }
    let(:indicators) { instance_double(Indicators) }

    let!(:tick) { create(:tick, symbol: "EURUSD") }
    let(:provided_tick_data) { [tick] }
    let(:provided_ticks) { {"EURUSD" => provided_tick_data } }

    before do
      allow(File).to receive(:read).and_return(json_file_contents)
      allow(Dir).to receive(:exists?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      allow(Logger).to receive(:new).and_return(mock_logger)
      allow(mock_logger).to receive(:info)
      allow(mock_logger).to receive(:error)

      allow(TickProcessor).to receive(:new).and_return(tick_processor)
      allow(Indicators).to receive(:new).and_return(indicators)

      allow(tick_provider).to receive(:more_ticks?).and_return(true, false)
      allow(tick_provider).to receive(:get_next_ticks).and_return(provided_ticks)

      allow(tick_processor).to receive(:process)
    end

    context "the configuration is nil for the strategy" do
      before do
        allow(JSON).to receive(:parse).and_return(nil)
      end

      it "will raise an error" do
        expect { run! }.to raise_error(Modules::Configuration::Configurable::MissingStrategyConfigurationError)
      end
    end

    context "the strategy is a back test" do
      let(:tick_provider) { instance_double(DataProviders::TickProviders::BackTestTickProvider) }
      let(:candle_provider) { instance_double(DataProviders::CandleProviders::BackTestCandleProvider) }
      let(:position_opener) { instance_double(Positions::PositionOpeners::BackTestPositionOpener) }
      let(:position_closer) { instance_double(Positions::PositionClosers::BackTestPositionCloser) }
      let(:position_tracker) { instance_double(Positions::PositionTrackers::BackTestPositionTracker) }
      let(:account) { create(:back_test_account) }
      let(:back_test) do
        create(
          :back_test,
          risk_pct: risk_pct,
          commission_pct: commission_pct,
          symbols: symbols,
          strategy_class: "BaseStrategy",
          end_date: nil,
          created_at: DateTime.parse(start_date),
          back_test_account: account
        )
      end

      before do
        allow(DataProviders::TickProviders::BackTestTickProvider).to receive(:new).with(
          symbols: symbols,
          start_date: DateTime.parse(start_date),
          end_date: DateTime.parse(end_date),
          strategy: anything
        ).and_return(tick_provider)
        allow(DataProviders::CandleProviders::BackTestCandleProvider).to receive(:new).with(
          symbols: symbols,
          strategy: anything
        ).and_return(candle_provider)
        allow(Positions::PositionOpeners::BackTestPositionOpener).to receive(:new).with(
          strategy: anything
        ).and_return(position_opener)
        allow(BackTest).to receive(:create!).with(
          strategy_class: "BaseStrategy",
          risk_pct: risk_pct,
          commission_pct: commission_pct,
          symbols: symbols
        ).and_return(back_test)
        allow(Accounts::BackTestAccount).to receive(:create!).and_return(account)
        allow(Positions::PositionTrackers::BackTestPositionTracker).to receive(:new).with(strategy: anything).and_return(position_tracker)
      end

      it "will process the tick" do
        expect(tick_processor).to receive(:process).with(tick: tick, strategy: anything)
        run!
      end

      context "there is no tick data" do
        let(:provided_tick_data) { [] }

        it "will not attempt to process anything" do
          expect(tick_processor).to_not receive(:process)
          run!
        end
      end
    end
  end
end