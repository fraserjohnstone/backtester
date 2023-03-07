class AddExpiresAfterToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :expires_after_minutes, :integer
  end
end
