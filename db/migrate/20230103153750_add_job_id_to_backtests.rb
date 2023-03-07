class AddJobIdToBacktests < ActiveRecord::Migration[7.0]
  def change
    add_column :backtests, :job_id, :string
  end
end
