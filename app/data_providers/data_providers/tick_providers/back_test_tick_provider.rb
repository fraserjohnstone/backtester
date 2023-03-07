module DataProviders
  module TickProviders
    class BackTestTickProvider
      attr_reader :start_date, :end_date, :symbols, :in_memory_ticks, :current_date, :current_minute, :strategy

      def initialize(symbols:, start_date:, end_date:, strategy:)
        @symbols = symbols
        @start_date = start_date
        @end_date = end_date
        @current_date = start_date
        @strategy = strategy

        progress_to_next_valid_day

        if @ticks_for_day.nil?
          initially_populate_ticks_for_day
        end

        @in_memory_ticks = {}
        @current_minute = 0

        load_ticks_into_memory
      end

      def get_next_ticks
        symbols.each_with_object({}) do |symbol, obj|
          obj[symbol] = in_memory_ticks[symbol][current_minute] || []
        end.tap do
          @current_minute += 1

          if current_minute > 1439
            @current_minute = 0
            @current_date += 1.day
            progress_to_next_valid_day
            load_ticks_into_memory
          end
        end
      end

      def more_ticks?
        current_date < end_date
      end

      def current_date_time
        @current_date.beginning_of_day + @current_minute.minutes
      end

      private

      def load_ticks_into_memory
        strategy.log.info("#{self.class} Loading ticks for new day #{@current_date}")
        symbols.each do |symbol|
          strategy.log.info("#{self.class}  - Loading for #{symbol}")
          in_memory_ticks[symbol] = ticks_for_symbol_by_minute(symbol: symbol)
        end
        strategy.log.info("#{self.class} --- Ticks loaded into memory")
      end

      def ticks_for_symbol_by_minute(symbol:)
        if @ticks_for_day[symbol].present?
          @ticks_for_day[symbol].group_by(&:minute_of_day)
        else
          (0..1439).each_with_object({}) do |i, h|
            h[i] = []
          end
        end
      end

      def ticks_for_day_exist?
        @ticks_for_day = Tick.where(symbol: symbols, date_time: current_date.beginning_of_day..current_date.end_of_day).group_by(&:symbol)
        @ticks_for_day.values.flatten.any?
      end

      def initially_populate_ticks_for_day
        @ticks_for_day = Tick.where(symbol: symbols, date_time: current_date.beginning_of_day..current_date.end_of_day).group_by(&:symbol)
      end

      def progress_to_next_valid_day
        @current_date += 1.day until @current_date.strftime("%A") != "Saturday" && ticks_for_day_exist?
      end
    end
  end
end