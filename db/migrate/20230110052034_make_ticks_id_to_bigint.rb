class MakeTicksIdToBigint < ActiveRecord::Migration[7.0]
  def change
    change_column :ticks, :id, :bigint
  end
end
