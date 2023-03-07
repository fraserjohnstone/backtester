class AddStatusToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :status, :string
  end
end
