class RemoveUnusedFieldsFromBackTests < ActiveRecord::Migration[7.0]
  def change
    remove_column :back_tests, :num_ticks_processed, :float
    add_column :back_tests, :symbols, :json
    add_column :back_tests, :start_date, :datetime
    add_column :back_tests, :end_date, :datetime
  end
end
