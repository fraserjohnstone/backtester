class TickWriter
  include ActionView::Helpers::DateHelper

  MAX_RECORDS_BEFORE_INSERT = 2000000

  def self.progress
    100 * (Dir["#{Rails.root.join("tick_write_progress")}/**/*"].count.to_f / Dir["#{Rails.root.join("tick_data")}/**/*.csv"].count).to_f
  end

  def initialize
    @record_datas = []
  end

  def write(symbols)
    symbols.each do |symbol|
      progress_file_marker_dir = Rails.root.join("tick_write_progress", symbol)
      FileUtils.mkdir_p(progress_file_marker_dir) unless Dir.exists?(progress_file_marker_dir)

      files_processed = 0

      Dir.glob("#{Rails.root.join("tick_data")}/#{symbol}/*.csv").each do |path|
        files_processed += 1
        next if date_processed?(file_name: path.split(".")[-2].split("/").last, marker_dir: progress_file_marker_dir)

        CSV.foreach(Rails.root.join(path)).each_with_index do |row_data, index|
          next if index == 0

          date_time = DateTime.parse(row_data.first)
          minute_of_day = (date_time.hour * 60) + date_time.minute
          ask = row_data.second.to_f
          bid = row_data.third.to_f
          ask_volume = row_data.fourth.to_f
          bid_volume = row_data.last.to_f
          year = date_time.year
          month = date_time.month
          day = date_time.day

          @record_datas << {
            uuid: id_from_symbol(symbol: symbol, date_time: date_time),
            symbol: symbol,
            date_time: date_time,
            ask:ask,
            bid:bid,
            ask_volume:ask_volume,
            bid_volume:bid_volume,
            spread:(ask - bid).abs,
            year:year,
            month:month,
            day:day,
            minute_of_day:minute_of_day
          }

          p "#{@record_datas.count} - #{symbol} - File: #{files_processed} (ticks)"

          if @record_datas.count >= MAX_RECORDS_BEFORE_INSERT
            Tick.insert_all(@record_datas)
            @record_datas = []
          end
        end

        Tick.insert_all(@record_datas) if @record_datas.any?
        @record_datas = []

        log_processed_date(file_name: path.split(".")[-2].split("/").last, marker_dir: progress_file_marker_dir, records_processed: @record_datas.count)
      end

      Tick.insert_all(@record_datas) if @record_datas.any?
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
    Digest::UUID.uuid_v5(Tick::NAMESPACE_ID, uniq_str)
  end

  def symbol_int(symbol)
    symbol.chars.map do |char|
      (%w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z].index(char) + 1).to_s
    end.join
  end


end