class RebuildTicksAgain < ActiveRecord::Migration[7.0]
  def change
    # drop_table :ticks

    create_table :ticks, id: false do |t|
      t.string :uuid, primary: true, null: false
      t.string :symbol, index: true
      t.datetime :date_time, index: true
      t.float :ask
      t.float :bid
      t.float :ask_volume
      t.float :bid_volume
      t.float :spread
      t.integer :minute_of_day
      t.integer :year
      t.integer :month
      t.integer :day

      t.index [:date_time, :symbol], name: "index_ticks_on_time_sym"
    end
  end
end
