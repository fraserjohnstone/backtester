class AddBreakEvenToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :break_even, :boolean
    add_column :trades, :original_stop_loss, :float
  end
end
