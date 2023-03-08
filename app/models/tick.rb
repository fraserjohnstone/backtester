class Tick <ApplicationRecord
  NAMESPACE_ID = "b94b8c4e-8b4a-4dad-8da5-d13222d8123e"

  default_scope { order(date_time: :asc) }

  validates_presence_of :uuid, :symbol, :date_time, :bid, :ask, :ask_volume, :bid_volume, :spread, :minute_of_day

  def dst?
    return true if date_time > second_sun_march && date_time < first_sun_nov
    false
  end

  def second_sun_march
    year = date_time.year
    date = DateTime.parse("#{year}-03-08") # starting on the 8th means there has already been one sunday

    date += 1.day until date.strftime("%A") == "Sunday"
    date
  end

  def first_sun_nov
    year = date_time.year
    date = DateTime.parse("#{year}-11-01")

    date += 1.day until date.strftime("%A") == "Sunday"
    date
  end

  def spread_as_pct
    (spread / ask) * 100
  end
end