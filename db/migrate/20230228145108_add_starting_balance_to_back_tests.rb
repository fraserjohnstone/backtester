class AddStartingBalanceToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :starting_balance, :float
  end
end
