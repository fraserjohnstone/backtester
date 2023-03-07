require "rails_helper"

class Klass
  include SeriesHelper
end

describe SeriesHelper do
  let(:instance) { Klass.new }

  describe "crossing_bearish?" do
    subject(:crossing_bearish?) do
      instance.crossing_bearish?(
        series_1: series_1,
        series_2: series_2,
        period: period
      )
    end

    let(:series_1) { [1,5,4,7,6,8,2,4,5,9,3,4,5,2] }
    let(:series_2) { series_1.map { |val| val + 1 } }
    let(:period) { series_1.size }

    context "the series sizes do not match" do
      let(:series_2) { [1,2,3] }

      it "raises an error" do
        expect { crossing_bearish? }.to raise_error(SeriesHelper::InvalidSeriesSizeComparisonError)
      end
    end

    context "one or all of the series are empty" do
      context "both series are empty" do
        let(:series_1) { [] }
        let(:series_2) { [] }

        it "raises an error" do
          expect { crossing_bearish? }.to raise_error(SeriesHelper::EmptySeriesError)
        end
      end

      context "only one of the series is empty" do
        let(:series_1) { [1,2,4,3,5,7,6,8,9] }
        let(:series_2) { [] }

        it "raises an error" do
          expect { crossing_bearish? }.to raise_error(SeriesHelper::InvalidSeriesSizeComparisonError)
        end
      end

      context "the series are populated but with not enough values" do
        let(:series_1) { [1,2,3] }
        let(:series_2) { [4,5,6] }
        let(:period) { 10 }

        it "raises an error" do
          expect { crossing_bearish? }.to raise_error(SeriesHelper::InsufficientDataError)
        end
      end
    end

    context "the series are different lengths but both above the period" do
      let(:series_1) { [1,2,3,2,1] }
      let(:series_2) { [4,5,6] }
      let(:period) { 2 }

      it "will not raise an error" do
        expect { crossing_bearish? }.to_not raise_error(SeriesHelper::InsufficientDataError)
      end
    end

    it { is_expected.to be false }

    context "the first number of series_1 is higher than series_2" do
      let(:series_1) { [7,2,3,2,1] }
      let(:series_2) { [4,5,6,5,4] }

      it { is_expected.to be false }
    end

    context "the series cross but not at the last value" do
      let(:series_1) { [1.1, 1.2, 1.3, 1.4, 1.5, 1.6] }
      let(:series_2) { series_1.reverse }

      it { is_expected.to be false }

      context "the series are crossing bullishly" do
        let(:series_2) { [1.1, 1.2, 1.3, 1.4, 1.5, 1.6] }
        let(:series_1) { series_2.reverse }

        it { is_expected.to be false }
      end
    end

    context "the series cross at the last value" do
      let(:series_1) { [1,2,3,4,5,6] }
      let(:series_2) { [9,8,7,6,5,4] }

      it { is_expected.to be true }

      context "the series are crossing bullishly" do
        let(:series_1) { [9,8,7,6,5,4] }
        let(:series_2) { [1,2,3,4,5,6] }

        it { is_expected.to be false }
      end
    end
  end

  describe "crossing_bullish?" do
    subject(:crossing_bullish?) do
      instance.crossing_bullish?(
        series_1: series_1,
        series_2: series_2,
        period: period
      )
    end

    let(:series_1) { [1,5,4,7,6,8,2,4,5,9,3,4,5,2] }
    let(:series_2) { series_1.map { |val| val - 1 } }
    let(:period) { series_1.size }

    context "the series sizes do not match" do
      let(:series_2) { [1,2,3] }

      it "raises an error" do
        expect { crossing_bullish? }.to raise_error(SeriesHelper::InvalidSeriesSizeComparisonError)
      end
    end

    context "one or all of the series are empty" do
      context "both series are empty" do
        let(:series_1) { [] }
        let(:series_2) { [] }

        it "raises an error" do
          expect { crossing_bullish? }.to raise_error(SeriesHelper::EmptySeriesError)
        end
      end

      context "only one of the series is empty" do
        let(:series_1) { [1,2,4,3,5,7,6,8,9] }
        let(:series_2) { [] }

        it "raises an error" do
          expect { crossing_bullish? }.to raise_error(SeriesHelper::InvalidSeriesSizeComparisonError)
        end
      end

      context "the series are populated but with not enough values" do
        let(:series_1) { [1,2,3] }
        let(:series_2) { [4,5,6] }
        let(:period) { 10 }

        it "raises an error" do
          expect { crossing_bullish? }.to raise_error(SeriesHelper::InsufficientDataError)
        end
      end
    end

    context "the series are different lengths but both above the period" do
      let(:series_1) { [1,2,3,2,1] }
      let(:series_2) { [4,5,6] }
      let(:period) { 2 }

      it "will not raise an error" do
        expect { crossing_bullish? }.to_not raise_error(SeriesHelper::InsufficientDataError)
      end
    end

    it { is_expected.to be false }

    context "the first number of series_2 is higher than series_1" do
      let(:series_1) { [6.2, 4.1, 3.6, 6.7] }
      let(:series_2) { [9.11, 7.8, 9.2, 11.436] }

      it { is_expected.to be false }
    end

    context "the series cross but not at the last value" do
      let(:series_1) { series_2.reverse }
      let(:series_2) { [1.6, 1.5, 1.4, 1.3, 1.2, 1.1] }

      it { is_expected.to be false }

      context "the series are crossing bearishly" do
        let(:series_1) { [1.1, 1.2, 1.3, 1.4, 1.5, 1.6] }
        let(:series_2) { series_1.reverse }

        it { is_expected.to be false }
      end
    end

    context "the series cross at the last value" do
      let(:series_2) { [1,2,3,4,5,6] }
      let(:series_1) { [9,8,7,6,5,4] }

      it { is_expected.to be true }

      context "the series are crossing bullishly" do
        let(:series_2) { [9,8,7,6,5,4] }
        let(:series_1) { [1,2,3,4,5,6] }

        it { is_expected.to be false }
      end
    end
  end

  describe "#slope" do
    subject(:slope) { instance.slope(series: series) }

    let(:series) { [1,2,3,4,5,6,7,8,9,10] }

    it { is_expected.to eq 1.to_f }

    context "the slope is negative" do
      let(:series) { [-3, -2, -1, 0, 1, 2, 3].reverse }

      it { is_expected.to eq -1.to_f }
    end

    context "the slope is not an integer" do
      let(:series) { [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0] }

      it { is_expected.to eq 0.5 }
    end
  end

  describe "#converging?" do
    subject(:converging?) { instance.converging?(series_1: series_1, series_2: series_2, period: period) }

    let(:series_1) { [1, 2, 3, 4, 5] }
    let(:series_2) { [10, 9, 8, 7, 6] }
    let(:period) { series_1.length }

    it { is_expected.to be true }

    context "the series sizes do not match" do
      let(:series_2) { [1,2,3] }

      it "raises an error" do
        expect { converging? }.to raise_error(SeriesHelper::InvalidSeriesSizeComparisonError)
      end
    end

    context "one or all of the series are empty" do
      context "both series are empty" do
        let(:series_1) { [] }
        let(:series_2) { [] }

        it "raises an error" do
          expect { converging? }.to raise_error(SeriesHelper::EmptySeriesError)
        end
      end

      context "only one of the series is empty" do
        let(:series_1) { [1,2,4,3,5,7,6,8,9] }
        let(:series_2) { [] }

        it "raises an error" do
          expect { converging? }.to raise_error(SeriesHelper::InvalidSeriesSizeComparisonError)
        end
      end

      context "the series are populated but with not enough values" do
        let(:series_1) { [1,2,3] }
        let(:series_2) { [4,5,6] }
        let(:period) { 10 }

        it "raises an error" do
          expect { converging? }.to raise_error(SeriesHelper::InsufficientDataError)
        end
      end
    end

    context "the series are switched" do
      let(:series_1) { [10, 9, 8, 7, 6] }
      let(:series_2) { [1, 2, 3, 4, 5] }

      it { is_expected.to be true }
    end

    context "the numbers are negative" do
      let(:series_1) { [-1, -2, -3, -4, -5] }
      let(:series_2) { [-10, -9, -8, -7, -6] }

      it { is_expected.to be true }
    end

    context "the series are diverging" do
      let(:series_1) { [5.1, 5.2, 5.3, 5.4, 5.5] }
      let(:series_2) { [5.0, 4.9, 4.8, 4.7, 4.6] }

      it { is_expected.to be false }

      context "the numbers are negative" do
        let(:series_1) { [-1, -2, -3.3, -5.2] }
        let(:series_2) { [-1.0, 0.2, 1.2, 3.5] }

        it { is_expected.to be false }
      end
    end
  end
end
