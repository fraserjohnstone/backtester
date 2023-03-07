class AddProgressDateToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :progress_date, :datetime
  end
end
