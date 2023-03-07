class AddIndexToTicks < ActiveRecord::Migration[7.0]
  def change
    add_index :ticks, [:symbol, :year, :month, :day], name: 'searchable'
  end
end
