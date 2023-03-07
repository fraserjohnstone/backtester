class AddEndedAtToBacktests < ActiveRecord::Migration[7.0]
  def change
    add_column :backtests, :ended_at, :datetime
  end
end
