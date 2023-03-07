class CandleWriter
  include ActionView::Helpers::DateHelper

  MAX_RECORDS_BEFORE_INSERT = 2000000

  def self.progress
    100 * (Dir["#{Rails.root.join("candle_write_progress")}/**/*"].count.to_f / Dir["#{Rails.root.join("candle_data")}/**/*.csv"].count).to_f
  end

  def initialize
    @candle_datas = []
  end

  def write(symbols)
    symbols.each do |symbol|
      progress_file_marker_dir = Rails.root.join("candle_write_progress", symbol)
      FileUtils.mkdir_p(progress_file_marker_dir) unless Dir.exists?(progress_file_marker_dir)

      files_processed = 0

      Dir.glob("#{Rails.root.join("candle_data")}/#{symbol}/**/*.csv").each do |path|
        files_processed += 1
        path_without_extension = path.split(".")[-2]
        filename_without_extension = path_without_extension.split("/").last

        next if date_processed?(file_name: filename_without_extension, marker_dir: progress_file_marker_dir)

        timeframe = path_without_extension.split("/")[-2]

        CSV.foreach(Rails.root.join(path)).each_with_index do |row_data, index|
          next if index == 0

          date_time = DateTime.parse(row_data.first)

          @candle_datas << {
            uuid: id_from_symbol(symbol: symbol, date_time: date_time),
            symbol: symbol,
            timeframe: timeframe,
            open_time: date_time,
            open: row_data[1].to_f,
            high: row_data[2].to_f,
            low: row_data[3].to_f,
            close: row_data[4].to_f,
            volume: row_data[5].to_f * 1000000
          }

          p "#{@candle_datas.count} - #{symbol} - File: #{files_processed} (candles)"

          if @candle_datas.count >= MAX_RECORDS_BEFORE_INSERT
            Candle.insert_all(@candle_datas)
            @candle_datas = []
          end
        end

        Candle.insert_all(@candle_datas) if @candle_datas.any?
        @candle_datas = []

        log_processed_date(file_name: path.split(".")[-2].split("/").last, marker_dir: progress_file_marker_dir, records_processed: @candle_datas.count)
      end

      Candle.insert_all(@candle_datas) if @candle_datas.any?
    end
  end

  def date_processed?(file_name:, marker_dir:)
    path = "#{marker_dir}/#{file_name}"
    File.exists?(path)
  end

  def log_processed_date(file_name:, marker_dir:, records_processed:)
    path = "#{marker_dir}/#{file_name}"
    File.open(path, "w+") do |f|
      f.write(records_processed)
    end
  end

  def id_from_symbol(symbol:, date_time:)
    uniq_str = "#{symbol_int(symbol)}#{date_time.strftime("%Y%m%d%H%M%S%3N")}"
    Digest::UUID.uuid_v5(Candle::NAMESPACE_ID, uniq_str)
  end

  def symbol_int(symbol)
    symbol.chars.map do |char|
      (%w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z].index(char) + 1).to_s
    end.join
  end
end
