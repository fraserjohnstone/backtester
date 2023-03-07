class CreateEarningReports < ActiveRecord::Migration[7.0]
  def change
    create_table :earning_reports do |t|
      t.datetime :date_time, null: false, index: true
      t.string :symbol, null: false, index: true
      t.float :estimated_eps, null: false
      t.float :reported_eps, null: false
      t.float :surprise, null: false
      t.float :pct_change_by_eod

      t.json :following_day_ticks

      t.timestamps

      t.index [:symbol, :date_time], name: "sym_dt_index"
    end
  end
end
