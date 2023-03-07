require "rails_helper"

describe EarningReport do
  let(:instance) do
    described_class.new(
      symbol: symbol,
      date_time: date_time,
      reported_eps: reported_eps,
      estimated_eps: estimated_eps,
      surprise: surprise
    )
  end

  let(:symbol) { "MSFT" }
  let(:date_time) { DateTime.parse("2020-04-03 4 PM") }
  let(:reported_eps) { 1.2 }
  let(:estimated_eps) { 1.01 }
  let(:surprise) { 1.79 }

  describe "validations" do
    subject { instance }
    it { is_expected.to be_valid }

    context "the symbol is missing" do
      let(:symbol) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the date_time is missing" do
      let(:date_time) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the reported_eps is missing" do
      let(:reported_eps) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the estimated_eps is missing" do
      let(:estimated_eps) { nil }
      it { is_expected.to_not be_valid }
    end

    context "the surprise is missing" do
      let(:surprise) { nil }
      it { is_expected.to_not be_valid }
    end
  end
end
