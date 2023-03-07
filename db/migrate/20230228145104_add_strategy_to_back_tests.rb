class AddStrategyToBackTests < ActiveRecord::Migration[7.0]
  def change
    add_reference :back_tests, :strategy, polymorphic: true, index: true
  end
end
