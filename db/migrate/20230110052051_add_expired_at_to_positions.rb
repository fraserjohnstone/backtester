class AddExpiredAtToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :expired_at, :datetime
  end
end
