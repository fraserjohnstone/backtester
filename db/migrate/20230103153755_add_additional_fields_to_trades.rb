class AddAdditionalFieldsToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :spread_pips_at_open, :float
    add_column :trades, :spread_pips_at_close, :float
  end
end
