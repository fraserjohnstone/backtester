class MakePositionClosedAtNullable < ActiveRecord::Migration[7.0]
  def change
    change_column :positions, :closed_at, :datetime, null: true
  end
end
