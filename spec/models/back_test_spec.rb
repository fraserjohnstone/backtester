require "rails_helper"

describe BackTest do
  let(:instance) do
    described_class.new(strategy_class: strategy_class, back_test_account: back_test_account)
  end
  let(:strategy_class) { "SomeClass" }
  let(:back_test_account) { create(:back_test_account) }

  describe "validations" do
    subject { instance }

    it { is_expected.to be_valid }

    context "the strategy class is nil" do
      let(:strategy_class) { nil }
      it { is_expected.to_not be_valid }
    end
  end

  describe "defaults" do
    describe "risk_pct" do
      subject { instance.risk_pct }
      it { is_expected.to eq BackTest::DEFAULT_RISK_PCT }
    end

    describe "commission_pct" do
      subject { instance.commission_pct }
      it { is_expected.to eq BackTest::DEFAULT_COMMISSION_PCT }
    end

    describe "symbols" do
      subject { instance.symbols }
      it { is_expected.to eq BackTest::DEFAULT_SYMBOLS }
    end

    describe "start_date" do
      subject { instance.start_date }
      it { is_expected.to eq BackTest::DEFAULT_START_DATE }
    end

    describe "end_date" do
      subject { instance.end_date }
      it { is_expected.to eq BackTest::DEFAULT_END_DATE }
    end
  end

  describe "associations" do
    describe "positions count" do
      subject { instance.positions.count }
      it { is_expected.to eq 0 }
    end

    describe "back_test_account" do
      subject { instance.back_test_account }
      it { is_expected.to eq back_test_account }
    end

    context "there are multiple positions" do
      let(:position_1) { create(:open_position, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET) }
      let(:position_2) { create(:open_position, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET) }

      before do
        instance.save!
        instance.positions << position_1
        instance.positions << position_2
      end

      it "will return the instances" do
        expect(instance.positions.count).to eq 2
      end
    end

    describe "#account" do
      subject { instance.account }

      before do
        instance.save!
      end

      it { is_expected.to be back_test_account }
    end
  end

  describe "#finished?" do
    subject { instance.finished? }

    before do
      instance.save!
    end

    it { is_expected.to be false }

    context "the position has been closed" do
      before do
        instance.update(ended_at: DateTime.now)
      end

      it { is_expected.to be true }
    end
  end

  describe "#set_progress" do
    subject(:set_progress) { instance.set_progress(progress_date: progress_date) }

    let(:progress_date) { instance.start_date + 4.days }

    it "updates the record progress date" do
      expect { set_progress }.to change { instance.progress_date }.from(nil).to(progress_date)
    end

    context "the new date is before the back test start date" do
      let(:progress_date) { instance.start_date - 4.days }

      it "will not allow the update and throw an error" do
        expect { set_progress }.to raise_error(BackTest::InvalidProgressDateError)
      end
    end
  end

  describe "#progress_as_pct" do
    subject(:progress_as_pct) { instance.progress_as_pct }

    let(:instance) do
      described_class.new(
        strategy_class: strategy_class,
        back_test_account: back_test_account,
        start_date: start_date,
        end_date: end_date,
        progress_date: progress_date
      )
    end

    let(:start_date) { Date.parse("2020-01-01") }
    let(:end_date) { Date.parse("2020-01-30") }
    let(:progress_date) { nil }

    it { is_expected.to eq 0.0 }

    context "is a third of the way through" do
      let(:progress_date) { start_date + 10.days - 8.hours }

      it { is_expected.to eq 33.33 }
    end

    context "is half of the way through" do
      let(:progress_date) { start_date + 15.days - 12.hours }

      it { is_expected.to eq 50.0 }
    end

    context "is two thirds of the way through" do
      let(:progress_date) { start_date + 20.days - 16.hours }

      it { is_expected.to eq 66.67 }
    end
  end

  describe "#pct_changes" do
    subject(:pct_changes) { instance.pct_changes }

    let(:pos_1) { create(:closed_position, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET) }
    let(:pos_2) { create(:closed_position, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_MARKET) }
    let(:pos_3) { create(:closed_position, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_MARKET) }
    let(:pos_4) { create(:closed_position, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET) }
    let(:pos_5) { create(:closed_position, bias: Position::BIAS_BUY, position_type: Position::POSITION_TYPE_MARKET) }
    let(:pos_6) { create(:closed_position, bias: Position::BIAS_SELL, position_type: Position::POSITION_TYPE_MARKET) }

    before do
      allow(instance).to receive_message_chain(:positions, :closed).and_return [pos_1, pos_2, pos_3, pos_4, pos_5, pos_6]

      allow(pos_1).to receive(:pct_change).and_return(-20.9)
      allow(pos_2).to receive(:pct_change).and_return(50.4)
      allow(pos_3).to receive(:pct_change).and_return(-23.323)
      allow(pos_4).to receive(:pct_change).and_return(87.7)
      allow(pos_5).to receive(:pct_change).and_return(99)
      allow(pos_6).to receive(:pct_change).and_return(21.1)
    end

    it { is_expected.to eq [-20.9, 50.4, -23.323, 87.7, 99, 21.1] }
  end

  describe "#mean_pct_change" do
    subject(:mean_pct_change) { instance.mean_pct_change }

    let(:test_array) { [21.4, 55, 93.445, 2, 3, 57.90] }

    before do
      allow(instance).to receive(:pct_changes).and_return(test_array)
    end

    it { is_expected.to be_within(0.00000001).of(38.7908333333333) }

    context "negative numbers" do
      let(:test_array) { [-21.4, 55, -93.445, 2, -3, 57.90] }
      it { is_expected.to be_within(0.00000001).of(-0.4908333333333322) }
    end
  end
end