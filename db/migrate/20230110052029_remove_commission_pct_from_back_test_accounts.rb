class RemoveCommissionPctFromBackTestAccounts < ActiveRecord::Migration[7.0]
  def change
    remove_column :back_test_accounts, :commission_pct, :float
  end
end
