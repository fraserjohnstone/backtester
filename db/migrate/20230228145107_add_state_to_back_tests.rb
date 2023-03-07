class AddStateToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :state, :string
  end
end
