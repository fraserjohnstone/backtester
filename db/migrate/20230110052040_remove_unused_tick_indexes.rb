class RemoveUnusedTickIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :ticks, :day
    remove_index :ticks, :month
    remove_index :ticks, :year
  end
end
