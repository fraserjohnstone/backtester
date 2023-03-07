class Indicators
  include Math

  def atr(candles:, period: 14)
    data = data_subset(candles: candles)
    TechnicalAnalysis::Atr.calculate(data, period: period).reverse
  end

  def ema(candles:, period: 14)
    data = data_subset(candles: candles)
    TechnicalAnalysis::Ema.calculate(data, period: period, price_key: :close).reverse
  end

  def sma(candles:, period: 14)
    data = data_subset(candles: candles)
    TechnicalAnalysis::Sma.calculate(data, period: period, price_key: :close).reverse
  end

  def bb(candles:, period: 14)
    data = data_subset(candles: candles)
    TechnicalAnalysis::Bb.calculate(data, period: period, price_key: :close).reverse
  end

  def pfes(candles:, period: 14)
    series = candles.pluck(:close)

    pfe_series = []
    p_values = []

    series.each_with_index do |v, i|
      next unless i >= period

      numerator = p_numerator(series: series, period: period, i: i)
      denominator = p_denominator(series: series, period: period, i: i)
      p = 100 * (numerator/denominator)

      if series[i] < series[i - 1]
        p = p * -1
      end

      p_values << {close: p, date_time: candles[i].open_time}

      next if p_values.count < period

      pfei = ema(candles: p_values, period: period).map(&:ema).last

      pfe_series << pfei
    end

    pfe_series
  end

  private

  def p_numerator(series:, period:, i:)
    sqrt(((series[i] - series[i - period]) ** 2) + (period ** 2))
  end

  def p_denominator(series:, period:, i:)
    values_to_sum = []

    (0..period-2).each do |j|
      values_to_sum << sqrt(((series[i - j] - series[i - j - 1]) ** 2) + 1)
    end

    values_to_sum.sum
  end

  def data_subset(candles:)
    candles.map(&:to_h)
  end
end