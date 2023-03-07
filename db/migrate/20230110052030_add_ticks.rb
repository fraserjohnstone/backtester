class AddTicks < ActiveRecord::Migration[7.0]
  def change
    create_table :ticks do |t|
      t.string :symbol, index: true
      t.datetime :date_time, index: true
      t.float :ask
      t.float :bid
      t.float :ask_volume
      t.float :bid_volume
      t.float :spread
      t.integer :minute_of_day
      t.integer :year, index: true
      t.integer :month, index: true
      t.integer :day, index: true
    end
  end
end
