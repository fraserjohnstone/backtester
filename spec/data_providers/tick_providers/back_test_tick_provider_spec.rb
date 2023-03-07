require "rails_helper"

describe DataProviders::TickProviders::BackTestTickProvider do
  let(:instance) { described_class.new(symbols: symbols, start_date: start_date, end_date: end_date, strategy: strategy) }
  let(:back_test) { instance_double(BackTest) }
  let(:strategy) { instance_double(Strategies::BaseStrategy, back_test: back_test) }
  let(:symbols) { ["EURUSD"] }
  let(:start_date) { DateTime.parse("2019-01-01") }
  let(:end_date) { DateTime.parse("2020-01-01") }
  let(:returned_ticks) { [create(:tick, symbol: "EURUSD")] }

  before do
    allow(Tick).to receive(:where).with(symbol: "EURUSD", date_time: anything).and_return(returned_ticks)
    allow(strategy).to receive_message_chain(:log, :info)
    allow(back_test).to receive(:update)
  end

  describe "#more_ticks?" do
    subject(:more_ticks?) { instance.more_ticks? }

    it { is_expected.to be true }

    context "when the start_date is the same as the end_date" do
      let(:end_date) { start_date }

      it { is_expected.to be false }
    end
  end

  describe "#get_next_ticks" do
    it "will load ticks into memory once" do
      expect(Tick).to receive(:where).with(symbol: "EURUSD", date_time: anything).twice
      instance.get_next_ticks
    end

    describe "progressing less than a days worth of minutes" do
      it "will not load ticks into memory" do
        100.times do
          instance.get_next_ticks
        end
        expect(Tick).to have_received(:where).with(symbol: "EURUSD", date_time: anything).twice
      end
    end

    describe "progressing more than a days worth of minutes but less than 2 days" do
      it "will not load ticks into memory", :aggregate_failures do
        1600.times do
          instance.get_next_ticks
        end
        expect(Tick).to have_received(:where).with(symbol: "EURUSD", date_time: anything).exactly(4).times
        expect(back_test).to have_received(:update).with(progress_date: anything).once
      end
    end

    describe "progressing more than 2 days worth of minutes" do
      it "will not load ticks into memory" do
        3500.times do
          instance.get_next_ticks
        end
        expect(Tick).to have_received(:where).with(symbol: "EURUSD", date_time: anything).exactly(6).times
        expect(back_test).to have_received(:update).with(progress_date: anything).at_least(2).times
      end
    end
  end
end