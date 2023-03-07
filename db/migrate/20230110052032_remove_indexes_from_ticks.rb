class RemoveIndexesFromTicks < ActiveRecord::Migration[7.0]
  def change
    remove_index :ticks, :year
    remove_index :ticks, :month
    remove_index :ticks, :day
    remove_index :ticks, :symbol
    remove_index :ticks, :date_time
  end
end
