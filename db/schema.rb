# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_28_145109) do
  create_table "back_test_accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "starting_balance"
    t.float "current_balance"
  end

  create_table "back_tests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "commission_pct"
    t.string "strategy_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ended_at"
    t.float "risk_pct"
    t.json "symbols"
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "back_test_account_id"
    t.datetime "progress_date"
    t.boolean "destroying"
    t.integer "pending_position_expiry_period"
    t.float "target_profit_to_loss_ratio"
    t.boolean "trail_stops"
    t.boolean "break_even"
    t.boolean "take_profit"
    t.string "strategy_type"
    t.bigint "strategy_id"
    t.float "max_spread"
    t.string "state"
    t.float "starting_balance"
    t.json "ticks_processed_in_period"
    t.index ["back_test_account_id"], name: "index_back_tests_on_back_test_account_id"
    t.index ["strategy_type", "strategy_id"], name: "index_back_tests_on_strategy"
  end

  create_table "candles", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "symbol"
    t.string "timeframe"
    t.float "open"
    t.float "high"
    t.float "low"
    t.float "close"
    t.float "volume"
    t.datetime "open_time"
    t.index ["open_time"], name: "index_candles_on_open_time"
    t.index ["symbol", "timeframe", "open_time"], name: "index_candles_on_open_time_plus"
    t.index ["symbol"], name: "index_candles_on_symbol"
    t.index ["timeframe"], name: "index_candles_on_timeframe"
  end

  create_table "earning_reports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "date_time", null: false
    t.string "symbol", null: false
    t.float "estimated_eps", null: false
    t.float "reported_eps", null: false
    t.float "surprise", null: false
    t.float "pct_change_by_eod"
    t.json "following_day_ticks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_time"], name: "index_earning_reports_on_date_time"
    t.index ["symbol", "date_time"], name: "sym_dt_index"
    t.index ["symbol"], name: "index_earning_reports_on_symbol"
  end

  create_table "positions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "back_test_id"
    t.string "symbol", null: false
    t.float "open_price", null: false
    t.float "stop_loss_price"
    t.float "original_stop_loss_price"
    t.float "close_price"
    t.float "take_profit_price"
    t.float "lot_size", null: false
    t.float "risk_as_money", null: false
    t.float "commission_as_money", null: false
    t.float "gross_profit"
    t.datetime "opened_at", null: false
    t.datetime "closed_at", precision: nil
    t.integer "state", null: false
    t.integer "bias", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position_type"
    t.datetime "expired_at"
    t.bigint "hedge_position_for_id"
    t.bigint "hedge_position_id"
    t.float "time_alive"
    t.index ["back_test_id"], name: "index_positions_on_back_test_id"
    t.index ["hedge_position_for_id"], name: "index_positions_on_hedge_position_for_id"
    t.index ["hedge_position_id"], name: "index_positions_on_hedge_position_id"
    t.index ["symbol"], name: "index_positions_on_symbol"
  end

  create_table "strategies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.json "relevant_candle_timeframes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "ticks", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "symbol"
    t.datetime "date_time"
    t.float "ask"
    t.float "bid"
    t.float "ask_volume"
    t.float "bid_volume"
    t.float "spread"
    t.integer "minute_of_day"
    t.integer "year"
    t.integer "month"
    t.integer "day"
    t.index ["date_time", "symbol"], name: "index_ticks_on_time_sym"
    t.index ["date_time"], name: "index_ticks_on_date_time"
    t.index ["symbol"], name: "index_ticks_on_symbol"
  end

  add_foreign_key "positions", "positions", column: "hedge_position_for_id"
  add_foreign_key "positions", "positions", column: "hedge_position_id"
end
