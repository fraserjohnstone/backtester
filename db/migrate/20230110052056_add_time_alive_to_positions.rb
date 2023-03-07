class AddTimeAliveToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :time_alive, :float
  end
end
