module Modules
  module Loggable
    def with_logging
      create_log_dir

      log.info("-------------------------------")
      log.info("|----  Starting Strategy  ----|")
      log.info("-------------------------------")
      log.info " "

      yield
    rescue => e
      log.error "ERROR - #{e.full_message}"
      summary[:errors] << e.full_message
    ensure
      log.info " "
      log.info "|---------  Summary  ---------|"
      log.info " "

      summary.each_pair do |k, v|
        log.info "#{k.to_s.titleize}: #{v}"
      end
    end

    def create_log_dir
      FileUtils.mkdir_p(log_path) unless Dir.exists?(log_path)
    end

    def log_path
      Rails.root.join("log", "strategies", "#{@runner.strategy.name.underscore}")
    end

    def log
      @log ||= Logger.new("#{log_path}/#{DateTime.now.to_s.gsub(":", "-").split("+").first}.log")
    end

    def summary
      @summary ||= {
        num_ticks_processed: 0,
        errors: []
      }
    end
  end
end
