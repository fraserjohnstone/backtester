class StrategiesController < ApplicationController
  skip_forgery_protection
  def index
    @strategies = Strategy.all
  end

  def destroy
    strategy = Strategy.find(params[:strategy_id])
    strategy.destroy

    new_file_name = Rails.root.join("app", "strategies", "#{strategy.name.underscore}.rb")
    File.delete(new_file_name) {} if File.exists?(new_file_name)

    redirect_to strategies_path
  end

  def new
    @strategy = Strategy.new(
      relevant_candle_timeframes: ["m5", "h4"],
    )
  end

  def edit
    @strategy = Strategy.find(params[:id])
  end

  def create
    new_file_name = Rails.root.join("app", "strategies", "#{create_update_params[:name].underscore}.rb")
    unless File.exists?(new_file_name)
      File.open(new_file_name, "w+") do |f|
        content = File.read(Rails.root.join("lib", "strategies", "example_files", "strategy.rb.example"))
        content = content.gsub("<CLASS_NAME>", create_update_params[:name])

        candle_methods = create_update_params[:relevant_candle_timeframes].each_with_object("") do |tf, str|
          str << "  def update_#{tf}_candle_indicators(date_time:, symbol:)\n    \#@#{tf}_ema_50s[symbol] = indicators.ema(candles: @#{tf}_candles[symbol], period: 50).map(&:ema)\n    \#@#{tf}_ema_100s[symbol] = indicators.ema(candles: @#{tf}_candles[symbol], period: 100).map(&:ema)\n  end\n\n"
        end

        content = content.gsub("<CANDLE_INDICATOR_METHODS>", candle_methods)

        f.write(content)

        unless Object.const_defined?(create_update_params[:name])
          Object.class_eval(content, create_update_params[:name])
        end
      end
    end

    create_update_params[:name].constantize.find_or_create_by!(name: create_update_params[:name]) do |s|
      s.relevant_candle_timeframes = create_update_params[:relevant_candle_timeframes]
    end

    redirect_to strategies_path
  end

  private

  def create_update_params
    params.require(:strategy).permit(
      :name,
      relevant_candle_timeframes: []
    ).to_h.with_indifferent_access.tap do |h|
      h[:name] = h[:name].gsub(/-_/, " ").downcase.titleize.delete(" ")
      h[:relevant_candle_timeframes] = h[:relevant_candle_timeframes].reject { |e| e == "0" }
    end
  end
end