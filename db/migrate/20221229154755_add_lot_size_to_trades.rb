class AddLotSizeToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :opened_at, :datetime
    add_column :trades, :lot_size, :float
  end
end
