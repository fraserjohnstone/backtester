class AddCandles < ActiveRecord::Migration[7.0]
  def change
    create_table :candles do |t|
      t.string :symbol, index: true
      t.string :timeframe, index: true

      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :volume
      t.datetime :open_time, index: true
    end
  end
end
