class AddCommissionToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :commission_as_money, :float
    add_column :trades, :net_profit, :float
    rename_column :trades, :profit, :gross_profit
  end
end
