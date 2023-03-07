class AddTrades < ActiveRecord::Migration[7.0]
  def change
    create_table :trades do |t|
      t.references :backtest, index: true
      t.float :profit
      t.float :open
      t.float :close
      t.float :take_profit
      t.float :stop_loss
      t.datetime :closed_at
      t.string :type
      t.string :bias

      t.timestamps
    end
  end
end
