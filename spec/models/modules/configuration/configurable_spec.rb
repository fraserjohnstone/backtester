require "rails_helper"

module My
  class Strategy
    include Modules::Configuration::Configurable
  end
end

describe Modules::Configuration::Configurable do
  let(:instance) { My::Strategy.new }
  let(:json_file_contents) do
    {
      strategy: {
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
  let(:symbols) { ["EURUSD", "AUDCAD"] }
  let(:start_date) { "2012-03-02" }
  let(:end_date) { "2015-02-07" }
  let(:risk_pct) { "0.34" }
  let(:commission_pct) { "4.1" }

  before do
    allow(File).to receive(:read).with(Modules::Configuration::Configurable::CONFIG_PATH).and_return(json_file_contents)
  end

  describe "#back_test?" do
    subject { instance.back_test? }

    it { is_expected.to be true }

    context "the configuration is set to live" do
      let(:mode) { Modules::Configuration::Configurable::MODE_LIVE }

      it { is_expected.to be false }
    end
  end

  describe "#mode" do
    subject { instance.mode }

    it { is_expected.to eq Modules::Configuration::Configurable::MODE_BACK_TEST }

    context "the configuration is set to live" do
      let(:mode) { Modules::Configuration::Configurable::MODE_LIVE }

      it { is_expected.to eq Modules::Configuration::Configurable::MODE_LIVE }
    end
  end

  describe "#symbols" do
    subject { instance.symbols }

    it { is_expected.to eq symbols }
  end

  describe "#back_test_start_date" do
    subject { instance.back_test_start_date }

    it { is_expected.to eq DateTime.parse(start_date) }

    context "the configuration is set to live" do
      let(:mode) { Modules::Configuration::Configurable::MODE_LIVE }

      it "will raise an error" do
        expect { subject }.to raise_error(Modules::Configuration::Configurable::NotBackTestError)
      end
    end
  end

  describe "#back_test_end_date" do
    subject { instance.back_test_end_date }

    it { is_expected.to eq DateTime.parse(end_date) }

    context "the configuration is set to live" do
      let(:mode) { Modules::Configuration::Configurable::MODE_LIVE }

      it "will raise an error" do
        expect { subject }.to raise_error(Modules::Configuration::Configurable::NotBackTestError)
      end
    end
  end

  describe "#back_test_risk_pct" do
    subject { instance.back_test_risk_pct }

    it { is_expected.to eq risk_pct }

    context "the configuration is set to live" do
      let(:mode) { Modules::Configuration::Configurable::MODE_LIVE }

      it "will raise an error" do
        expect { subject }.to raise_error(Modules::Configuration::Configurable::NotBackTestError)
      end
    end
  end

  describe "#back_test_commission_pct" do
    subject { instance.back_test_commission_pct }

    it { is_expected.to eq commission_pct }

    context "the configuration is set to live" do
      let(:mode) { Modules::Configuration::Configurable::MODE_LIVE }

      it "will raise an error" do
        expect { subject }.to raise_error(Modules::Configuration::Configurable::NotBackTestError)
      end
    end
  end
end