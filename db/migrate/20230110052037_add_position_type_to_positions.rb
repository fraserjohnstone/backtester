class AddPositionTypeToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :position_type, :integer
    rename_column :positions, :spread_history, :tick_history
  end
end
