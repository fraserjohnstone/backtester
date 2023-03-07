class AddDestroyingToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_column :back_tests, :destroying, :boolean
  end
end
