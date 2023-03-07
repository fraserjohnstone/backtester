class ChangeStoredProfitTypeOnPositions < ActiveRecord::Migration[7.0]
  def change
    rename_column :positions, :net_profit, :gross_profit
    remove_column :positions, :tick_history
  end
end
