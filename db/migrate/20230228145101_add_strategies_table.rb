class AddStrategiesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :strategies do |t|
      t.string :name, index: true, nullable: false
      t.json :relevant_candle_timeframes
      t.float :max_spread
      t.float :lot_size_modifier
      t.integer :pending_position_expiry_period
      t.boolean :take_profit
      t.boolean :trail_stops
      t.float :profit_to_loss_ratio
      t.string :mode
      t.json :symbols
      t.datetime :back_test_start_date
      t.datetime :back_test_end_date
      t.float :risk_pct
      t.float :back_test_commission_pct

      t.timestamps
    end
  end
end
