class AddProgressAsPctToBacktests < ActiveRecord::Migration[7.0]
  def change
    add_column :backtests, :progress_as_pct, :float
  end
end
