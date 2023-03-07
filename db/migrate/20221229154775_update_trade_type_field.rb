class UpdateTradeTypeField < ActiveRecord::Migration[7.0]
  def change
    rename_column :trades, :type, :order_type
    add_column :trades, :risk_as_money, :float
  end
end
