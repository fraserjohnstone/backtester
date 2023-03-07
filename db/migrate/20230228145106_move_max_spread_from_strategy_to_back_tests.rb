class MoveMaxSpreadFromStrategyToBackTests < ActiveRecord::Migration[7.0]
  def change
    remove_column :strategies, :max_spread, :float
    add_column :back_tests, :max_spread, :float
  end
end
