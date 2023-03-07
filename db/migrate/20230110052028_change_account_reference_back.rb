class ChangeAccountReferenceBack < ActiveRecord::Migration[7.0]
  def change
    remove_column :back_tests, :account_id, :bigint
    add_reference :back_tests, :back_test_account
  end
end
