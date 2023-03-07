class EarningReport < ApplicationRecord
  validates_presence_of :symbol, :date_time, :reported_eps, :estimated_eps, :surprise

  default_scope -> { order(:date_time) }
  scope :historic, -> { where.not(pct_change_by_eod: nil) }

  after_create :set_following_day_ticks
  after_create :set_pct_change_by_eod

  def pct_change_by_eod
    if super.nil?
      set_following_day_ticks
      set_pct_change_by_eod
    end
    super
  end

  def max_till_eod(side:)
    following_prices(side: side).max_by { |_, v| v }
  end

  def min_till_eod(side:)
    following_prices(side: side).min_by { |_, v| v }
  end

  def expected_change_by_eod?
    return true if surprise.positive? && pct_change_by_eod&.positive?
    return true if surprise.negative? && pct_change_by_eod&.negative?
    return false
  end

  def following_prices(side:)
    raise "No Following Day Tick Data" if following_day_ticks == nil
    following_day_ticks.each_with_object({}) do |(dt, data), hash|
      hash[dt] = data[side]
    end
  end

  def min_hit_first?(side:)
    min_till_eod(side: side).first < max_till_eod(side: side).first
  end

  def max_hit_first?(side:)
    max_till_eod(side: side).first < min_till_eod(side: side).first
  end

  private

  def set_following_day_ticks
    return unless DateTime.now > date_time + 2.days

    ticks = Tick.where(symbol: symbol, date_time: date_time..date_time.end_of_day)

    unless ticks.empty?
      hashed_ticks = ticks.each_with_object({}) do |t, hash|
        hash[t.date_time] = { ask: t.ask, bid: t.bid }
      end

      update(following_day_ticks: hashed_ticks)
    end
  end

  def set_pct_change_by_eod
    return unless following_day_ticks.present?

    most_recent = surprise.positive? ? most_recent_price(side: "ask") : most_recent_price(side: "bid")
    eod = surprise.positive? ? eod_price(side: "bid") : eod_price(side: "ask")

    difference = eod - most_recent
    update(pct_change_by_eod: (difference/most_recent) * 100)
  end

  def eod_price(side:)
    raise "No Following Day Tick Data" if following_day_ticks == nil
    following_day_ticks.values.last[side]
  end

  def most_recent_price(side:)
    raise "No Following Day Tick Data" if following_day_ticks == nil
    following_day_ticks.values.first[side]
  end
end

