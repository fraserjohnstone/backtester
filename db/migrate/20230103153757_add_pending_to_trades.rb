class AddPendingToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :pending, :boolean
  end
end
