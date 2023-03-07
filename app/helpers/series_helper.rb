module SeriesHelper
  class InvalidSeriesSizeComparisonError < StandardError; end
  class InsufficientDataError < StandardError; end
  class EmptySeriesError < StandardError; end

  # true is series_2 crosses from above to below series_1
  def crossing_bearish?(series_1:, series_2:, period:)
    series_1, series_2 = validate_series(series_1: series_1, series_2: series_2, period: period)

    return false if series_1.first > series_2.first

    differences = calculate_differences(series_1: series_1, series_2: series_2)
    previous_differences = differences[..-2]
    current_difference = differences.last

    return true if current_difference.negative? && all_pos_or_zero?(series: previous_differences)
    return false
  end

  # true is series_2 crosses from below to above series_1
  def crossing_bullish?(series_1:, series_2:, period:)
    series_1, series_2 = validate_series(series_1: series_1, series_2: series_2, period: period)

    return false if series_2.first > series_1.first

    differences = calculate_differences(series_1: series_1, series_2: series_2)
    previous_differences = differences[..-2]
    current_difference = differences.last

    return true if current_difference.positive? && all_neg_or_zero?(series: previous_differences)
    return false
  end

  def converging?(series_1:, series_2:, period: nil)
    period = series_1.length if period.nil?

    series_1 = series_1.last(period)
    series_2 = series_2.last(period)

    raise InvalidSeriesSizeComparisonError.new if series_1.length != series_2.length
    raise EmptySeriesError.new if series_1.length == 0
    raise InsufficientDataError.new if series_1.length < period

    differences = calculate_abs_differences(series_1: series_1, series_2: series_2)

    slope(series: differences) < 0
  end

  def diverging?(series_1:, series_2:, period: nil)
    !converging?(series_1: series_1, series_2: series_2, period: period)
  end

  def slope(series:)
    x2 = series.count
    x1 = 1.0
    y1 = series.first.to_f
    y2 = series.last.to_f

    (y2 - y1)/(x2 - x1).to_f
  end

  private

  def calculate_abs_differences(series_1:, series_2:)
    calculate_differences(series_1: series_1, series_2: series_2).map(&:abs)
  end

  def calculate_differences(series_1:, series_2:)
    series_1.zip(series_2).map { |(val_1, val_2)| val_2 - val_1 }
  end

  def all_pos_or_zero?(series:)
    series.all? { |val| val >= 0}
  end

  def all_neg_or_zero?(series:)
    series.all? { |val| val <= 0}
  end

  def validate_series(series_1:, series_2:, period:)
    series_1 = series_1.last(period)
    series_2 = series_2.last(period)

    raise InvalidSeriesSizeComparisonError.new if series_1.length != series_2.length
    raise EmptySeriesError.new if series_1.length == 0
    raise InsufficientDataError.new if series_1.length < period

    [series_1, series_2]
  end
end