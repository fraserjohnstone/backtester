class EarningReportsController < ApplicationController
  def index
    @symbol = "AAPL"

    data_hashes = EarningReport.historic.where(symbol: "AAPL").select { |r| r.expected_change_by_eod? }.map do |r|
      {surprise: r.surprise, pct_change_by_eod: r.pct_change_by_eod}
    end

    surprises = data_hashes.map { |element| element[:surprise] }
    pct_changes = data_hashes.map { |element| element[:pct_change_by_eod] }

    @series = [
      {
        name: "surprises",
        data: surprises
      },
      {
        name: "pct_changes",
        data: pct_changes
      }
    ]
  end

  def show
    @report = EarningReport.find(params[:id])

    @series = [
      {
        name: "ask",
        data: @report.following_prices(side: "ask")
      }
    ]
  end
end