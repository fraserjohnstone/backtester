class RebuildCandlesAgain < ActiveRecord::Migration[7.0]
  def change
    drop_table :candles

    create_table :candles, id: false do |t|
      t.string :uuid, primary: true, null: false

      t.string :symbol, index: true
      t.string :timeframe, index: true
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :volume
      t.datetime :open_time, index: true
      t.index [:symbol, :timeframe, :open_time], name: "index_candles_on_open_time_plus"
    end
  end
end
