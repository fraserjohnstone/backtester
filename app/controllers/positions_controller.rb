class PositionsController < ApplicationController
  def index
    @back_test = BackTest.find(params[:back_test_id])
  end

  def positions_list_item_data
    position = Position.find(params[:id])

    render json: { html: render_to_string(partial: "positions/position_list_item", locals: {position: position}) }
  end

  def price_history_for_position
    position = Position.find(params[:id])

    raise "Attempting to display in progress trade" unless position.closed_at?

    duration = position.closed_at - position.opened_at
    candles = Candle.where(symbol: position.symbol, open_time: (position.opened_at - (duration * 5))..(position.closed_at + (duration * 5)), timeframe: position.best_candle_timeframe)

    max_y = candles.pluck(:high).max
    min_y = candles.pluck(:low).min
    data = candles.each_with_object([]) do |candle, arr|
      arr << {x: candle.open_time, y: [candle.open, candle.high, candle.low, candle.close]}
    end

    render json: { html: [{type: "candlestick", data: data}], maxY: max_y, minY: min_y }
  end

  def condense_array(arr, factor: 2, target: 2000)
    new_arr = []
    arr.each_with_index do |val, i|
      unless i % factor == 0
        new_arr << val
      end
    end

    if new_arr.count > target
      condense_array(new_arr, factor: factor, target: target)
    end

    new_arr
  end

  def indicators
    @indicators ||= Indicators.new
  end
end

