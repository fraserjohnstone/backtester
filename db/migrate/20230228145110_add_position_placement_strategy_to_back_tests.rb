class AddPositionPlacementStrategyToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :position_placement_strategy, :string
  end
end
