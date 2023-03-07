class AddBacktests < ActiveRecord::Migration[7.0]
  def change
    create_table :backtests do |t|
      t.float :starting_balance
      t.float :profit
      t.float :commission_pct
      t.bigint :num_ticks_processed
      t.string :strategy_class

      t.timestamps
    end
  end
end
