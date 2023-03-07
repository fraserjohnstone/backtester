class AddStrategyClassToBacktestCollections < ActiveRecord::Migration[7.0]
  def change
    add_column :backtest_collections, :strategy_class, :string
    add_column :backtests, :symbol, :string
  end
end
