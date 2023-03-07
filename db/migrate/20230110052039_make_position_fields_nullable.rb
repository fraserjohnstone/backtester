class MakePositionFieldsNullable < ActiveRecord::Migration[7.0]
  def change
    change_column :positions, :tick_history, :json, null: true
    change_column :positions, :net_profit, :float, null: true
  end
end
