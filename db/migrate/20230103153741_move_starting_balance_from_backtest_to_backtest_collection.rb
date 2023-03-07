class MoveStartingBalanceFromBacktestToBacktestCollection < ActiveRecord::Migration[7.0]
  def change
    remove_column :backtests, :starting_balance, :float
    add_column :backtest_collections, :starting_balance, :float
  end
end
