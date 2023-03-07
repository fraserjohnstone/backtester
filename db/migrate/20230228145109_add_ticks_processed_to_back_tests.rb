class AddTicksProcessedToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :ticks_processed_in_period, :json
  end
end
