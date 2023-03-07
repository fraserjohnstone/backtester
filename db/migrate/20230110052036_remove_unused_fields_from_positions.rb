class RemoveUnusedFieldsFromPositions < ActiveRecord::Migration[7.0]
  def change
    drop_table :positions

    create_table :positions do |t|
      t.references :back_test, index: true

      t.string :symbol, null: false, index: true

      t.float :open_price, null: false
      t.float :stop_loss_price, null: true
      t.float :original_stop_loss_price, null: true
      t.float :close_price
      t.float :take_profit_price

      t.float :lot_size, null: false
      t.float :risk_as_money, null: false
      t.float :commission_as_money, null: false
      t.float :net_profit, null: false

      t.datetime :opened_at, null: false
      t.datetime :closed_at, null: false

      t.integer :state, null: false
      t.integer :bias, null: false

      t.json :spread_history, null: false

      t.datetime :expires_at

      t.timestamps
    end

    change_column :positions, :id, :bigint
  end
end
