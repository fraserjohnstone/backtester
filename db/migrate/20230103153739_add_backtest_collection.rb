class AddBacktestCollection < ActiveRecord::Migration[7.0]
  def change
    create_table :backtest_collections do |t|
      t.timestamps
    end

    add_reference :backtests, :backtest_collection
  end
end
