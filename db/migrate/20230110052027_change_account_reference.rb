class ChangeAccountReference < ActiveRecord::Migration[7.0]
  def change
    remove_column :back_tests, :back_test_account_id
    add_column :back_tests, :account_id, :bigint
  end
end
