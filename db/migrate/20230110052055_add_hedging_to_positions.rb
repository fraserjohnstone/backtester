class AddHedgingToPositions < ActiveRecord::Migration[7.0]
  def change
    add_belongs_to :positions, :hedge_position_for, index: true, foreign_key: {to_table: :positions}
    add_belongs_to :positions, :hedge_position, index: true, foreign_key: {to_table: :positions}
  end
end
