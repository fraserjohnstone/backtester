class RenameTradesToPositions < ActiveRecord::Migration[7.0]
  def change
    rename_table :trades, :positions

  end
end
