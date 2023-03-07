class AddTerminateToBacktestCollections < ActiveRecord::Migration[7.0]
  def change
    add_column :backtest_collections, :terminate, :boolean
  end
end
