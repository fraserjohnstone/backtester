class AddSymbolToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :symbol, :string
    remove_column :backtests, :current_balance, :float
    remove_column :backtests, :profit, :float
  end
end
