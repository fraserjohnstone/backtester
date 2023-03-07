class AddTimeFieldsToBacktests < ActiveRecord::Migration[7.0]
  def change
    add_column :backtests, :first_tick_time, :datetime
    add_column :backtests, :last_tick_time, :datetime
    add_column :backtests, :latest_check_in_time, :datetime
    remove_column :backtests, :progress_as_pct, :float
  end
end
