class AddBackTestAccount < ActiveRecord::Migration[7.0]
  def change
    # drop_table :backtest_collections

    rename_table :backtests, :back_tests

    remove_column :back_tests, :symbol, :string
    remove_column :back_tests, :first_tick_time, :datetime
    remove_column :back_tests, :last_tick_time, :datetime
    remove_column :back_tests, :latest_check_in_time, :datetime
    remove_column :back_tests, :job_id, :string
    remove_reference :back_tests, :backtest_collection

    create_table :back_test_accounts do |t|
      t.float :starting_balance
      t.float :current_balance
      t.float :commission_pct
    end

    add_reference :back_tests, :back_test_account
  end
end
