class RebuildCandles < ActiveRecord::Migration[7.0]
  def change
    drop_table :candles

    create_table :candles, id: false do |t|
      t.string :uuid, primary: true, null: false

      t.string :symbol
      t.string :timeframe
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :volume
      t.datetime :open_time
      t.index [:symbol, :timeframe, :open_time], name: "index_candles_on_open_time"
    end
  end
end
