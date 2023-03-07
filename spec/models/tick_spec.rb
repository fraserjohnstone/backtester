require "rails_helper"

describe Tick do
  let(:instance) do
    described_class.new(
      uuid: uuid,
      symbol: symbol,
      date_time: date_time,
      bid: bid,
      ask: ask,
      ask_volume: ask_volume,
      bid_volume: bid_volume,
      spread: spread,
      minute_of_day: minute_of_day
    )
  end
  let(:uuid) { SecureRandom.uuid }
  let(:symbol) { "AUDCAD" }
  let(:date_time) { DateTime.parse("2021-11-03 12:#{minute_of_day}:03") }
  let(:bid) { 0.91696 }
  let(:ask) { 0.91923 }
  let(:ask_volume) { 1.32 }
  let(:bid_volume) { 1.12 }
  let(:spread) { 0.0022699999999999942 }
  let(:minute_of_day) { 32 }

  describe "validations" do
    subject { instance }
    it { is_expected.to be_valid }

    context "the uuid is missing" do
      let(:uuid) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the symbol is missing" do
      let(:symbol) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the date_time is missing" do
      let(:date_time) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the bid is missing" do
      let(:bid) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the ask is missing" do
      let(:ask) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the bid_volume is missing" do
      let(:bid_volume) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the ask_volume is missing" do
      let(:ask_volume) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the spread is missing" do
      let(:spread) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the minute_of_day is missing" do
      let(:minute_of_day) { nil }
      it { is_expected.to_not be_valid }
    end
  end
end