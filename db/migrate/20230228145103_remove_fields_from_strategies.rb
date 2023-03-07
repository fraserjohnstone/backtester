class RemoveFieldsFromStrategies < ActiveRecord::Migration[7.0]
  def change
    remove_column :strategies, :notes, :text
    remove_column :strategies, :tags, :json
    remove_column :strategies, :symbols, :json
    remove_column :strategies, :back_test_commission_pct, :float
    remove_column :strategies, :risk_pct, :float
    remove_column :strategies, :back_test_start_date, :datetime
    remove_column :strategies, :back_test_end_date, :datetime
    remove_column :strategies, :pending_position_expiry_period, :integer
    remove_column :strategies, :profit_to_loss_ratio, :float
    remove_column :strategies, :trail_stops, :boolean
    remove_column :strategies, :take_profit, :boolean

    remove_column :strategies, :lot_size_modifier, :json

    add_column :back_tests, :pending_position_expiry_period, :integer
    add_column :back_tests, :target_profit_to_loss_ratio, :float
    add_column :back_tests, :trail_stops, :boolean
    add_column :back_tests, :break_even, :boolean
    add_column :back_tests, :take_profit, :boolean
  end
end
