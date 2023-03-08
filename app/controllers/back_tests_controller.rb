class BackTestsController < ApplicationController
  def index
    @back_tests = BackTest.all
  end
  def new
    @back_test = BackTest.new
  end

  def edit
    @back_test = BackTest.find(params[:id])
  end

  def clone
    # back_test = BackTest.find(params[:id])
    new_back_test = create_back_test
    BackTestRunner.perform_later(back_test_id: new_back_test.id)

    if params[:destroy_existing] == "true"
      BackTest.find(params[:id]).destroy
    end

    redirect_to back_tests_path
  end

  def create
    back_test = create_back_test

    BackTestRunner.perform_later(back_test_id: back_test.id)

    redirect_to back_tests_path
  end

  def run
    redirect_to back_tests_path
  end

  def create_back_test
    strategy_class = create_update_params[:strategy_class]
    BackTest.create!(
      create_update_params.merge(
        {
          strategy_type: strategy_class,
          strategy_id: strategy_class.constantize.find_by(
            name: strategy_class
          ).id
        }
      )
    ).tap do |bt|
      bt.state = BackTest::STATE_READY
    end
  end

  def destroy_back_test
    bt = BackTest.find(params[:id])
    bt.update(destroying: true)
    redirect_to back_tests_path
  end

  def stop_back_test
    BackTest.find(params[:id]).manually_finish!
    redirect_to back_tests_path
  end

  def back_tests_list_item_data
    start = DateTime.now
    back_test = BackTest.find(params[:id])

    back_test_representation = {
      id: back_test.id,
      name: back_test.strategy_class.split(/(?=[A-Z])/).join(" ").titleize,
      started_at_readable: "#{back_test.id} - Started on #{back_test.created_at_readable}",
      balance_pct_change: "#{back_test.return_as_pct >= 0 ? "+" : "-"} #{back_test.return_as_pct.abs} %",
      starting_balance: ActionController::Base.helpers.number_to_currency(back_test.account&.starting_balance, unit: "£"),
      current_balance: ActionController::Base.helpers.number_to_currency(back_test.account&.current_balance, unit: "£"),
      net_balance: "(#{ActionController::Base.helpers.number_to_currency(back_test.account&.current_balance(net: true), unit: "£")})",
      profit_loss: ActionController::Base.helpers.number_to_currency(back_test.account&.current_balance - back_test.account&.starting_balance, unit: "£"),
      net_profit_loss: "(#{ActionController::Base.helpers.number_to_currency(back_test.account&.current_balance(net: true) - back_test.account&.starting_balance, unit: "£")})",
      time_elapsed: ActionController::Base.helpers.distance_of_time_in_words(back_test.life_time),
      time_remaining: back_test.estimated_time_left,
      model_progress: back_test.progress_date.present? ? "#{ActionController::Base.helpers.distance_of_time_in_words((back_test.progress_date&.to_i - back_test.start_date.to_i))}" : "Calculating...",
      model_period: ActionController::Base.helpers.distance_of_time_in_words((back_test.end_date.to_i - back_test.start_date.to_i)),
      pct_complete: "#{back_test.progress_as_pct}%",
      mean_pct_returns: "#{back_test.mean_pct_change.round(4)}%",
      std_dev: back_test.std_dev_pct_changes.round(4) || 0.0,
      sharpe_ratio: back_test.sharpe_ratio.round(4),
      total_position_count: back_test.positions.open.count +  back_test.positions.closed.count,
      open_position_count: back_test.positions.open.count,
      unrealised_pl: ActionController::Base.helpers.number_to_currency(back_test.unrealised_profit_loss, unit: "£"),
      wins_count: back_test.positions.closed.wins.count,
      wins_pct: "(#{((back_test.positions.wins.count.to_f/back_test.positions.closed.count) * 100).round(2)}%)",
      losses_count: back_test.positions.closed.losses.count,
      losses_pct: "(#{((back_test.positions.losses.count.to_f/back_test.positions.closed.count) * 100).round(2)}%)",
      avg_return: ActionController::Base.helpers.number_to_currency(back_test.average_return, unit: "£"),
      avg_win: ActionController::Base.helpers.number_to_currency(back_test.average_win, unit: "£"),
      avg_loss: ActionController::Base.helpers.number_to_currency(back_test.average_loss, unit: "£"),
      average_total_tick_time_series: back_test.ticks_processed_in_period.map { |d| d["time_taken"].to_f/10000 },
      average_skipped_tick_time_series: back_test.ticks_processed_in_period.map { |d| d["ticks_skipped"].to_f },
      average_processed_tick_time_series: back_test.ticks_processed_in_period.map { |d| d["ticks_processed"].to_f }
    }

    render json: back_test_representation
  end

  def profit_loss_series_for_back_test
    running_gross_balance = [0]
    running_net_balance = [0]


    BackTest.find(params[:id]).positions.closed.order(:closed_at).each do |pos|
      running_gross_balance << pos.gross_profit + running_gross_balance.last
      running_net_balance << pos.net_profit + running_net_balance.last
    end

    render json: { html: [{name: "Running Gross Balance", data: running_gross_balance}, {name: "Running Net Balance", data: running_net_balance}] }
  end

  def profit_loss_bars_for_back_test
    data = [
      {
        x: "Winnings",
        y: BackTest.find(params[:id]).positions.wins.pluck(:gross_profit).sum
      },
      {
        x: "Losses",
        y: BackTest.find(params[:id]).positions.losses.pluck(:gross_profit).map(&:abs).sum
      }
    ]

    render json: { html: [{name: "Profit vs Loss", data: data}] }
  end

  private

  def create_update_params
    params.require(:back_test).permit(
      :strategy_class,
      :start_date,
      :end_date,
      :starting_balance,
      :risk_pct,
      :commission_pct,
      :position_placement_strategy,
      symbols: [],
    ).to_h.with_indifferent_access.tap do |h|
      h[:symbols] = h[:symbols].reject { |e| e == "0" }
    end
  end
end