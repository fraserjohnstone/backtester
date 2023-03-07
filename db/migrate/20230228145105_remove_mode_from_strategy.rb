class RemoveModeFromStrategy < ActiveRecord::Migration[7.0]
  def change
    remove_column :strategies, :mode, :string
    remove_column :back_tests, :status, :string
  end
end
