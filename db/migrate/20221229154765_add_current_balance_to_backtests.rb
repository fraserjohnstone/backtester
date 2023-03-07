class AddCurrentBalanceToBacktests < ActiveRecord::Migration[7.0]
  def change
    add_column :backtests, :current_balance, :float
    add_column :backtests, :risk_pct, :float
  end
end
