require "rails_helper"

class LoggedKlass
  include Modules::Loggable

  def run!
    with_logging do
      log.info("I'm running from the block")
    end
  end
end

describe Modules::Loggable do
  let(:instance) { LoggedKlass.new }
  let(:mock_log_path) { "some/log/path" }
  let(:log_path_exists?) { false }
  let(:stubbed_date_time) { DateTime.parse("2020-02-03") }
  let(:expected_full_log_path) { "#{mock_log_path}/2020-02-03T00-00-00.log" }
  let(:mock_logger) { instance_double(Logger) }

  before do
    allow(Rails.root).to receive(:join).with("log", "strategies", "logged_klass").and_return(mock_log_path)
    allow(Dir).to receive(:exists?).with(mock_log_path).and_return(log_path_exists?)
    allow(FileUtils).to receive(:mkdir_p).with(mock_log_path)
    allow(Logger).to receive(:new).and_return(mock_logger)
    allow(DateTime).to receive(:now).and_return(stubbed_date_time)
    allow(mock_logger).to receive(:info)
    allow(mock_logger).to receive(:error)
  end

  describe "#create_log_dir" do
    subject(:create_log_dir) { instance.create_log_dir }

    it "will create the directory" do
      expect(FileUtils).to receive(:mkdir_p).with(mock_log_path)
      create_log_dir
    end
  end

  describe "#log_path" do
    subject(:log_path) { instance.log_path }

    it { is_expected.to eq mock_log_path }
  end

  describe "#log" do
    subject(:log) { instance.log }

    it "will return the entire log path" do
      expect(Logger).to receive(:new).with(expected_full_log_path)
      log
    end
  end

  describe "#summary" do
    subject(:summary) { instance.summary }

    let(:expected_summary) { {num_ticks_processed: 0, errors: []} }

    it { is_expected.to eq expected_summary }
  end

  describe "#with_logging through run!" do
    subject(:run!) { instance.run! }

    it "will create the log directory" do
      expect(FileUtils).to receive(:mkdir_p).with(mock_log_path)
      run!
    end

    context "the log path already exists" do
      let(:log_path_exists?) { true }

      it "will not create the log directory" do
        expect(FileUtils).to_not receive(:mkdir_p).with(mock_log_path)
        run!
      end
    end

    it "creates the log object" do
      expect(Logger).to receive(:new).with(expected_full_log_path)
      run!
    end

    it "will log the boilerplate messages", :aggregate_failures do
      expect(mock_logger).to receive(:info).with("|----  Starting Strategy  ----|")
      expect(mock_logger).to receive(:info).with("|---------  Summary  ---------|")
      expect(mock_logger).to receive(:info).with("Num Ticks Processed: 0")
      expect(mock_logger).to receive(:info).with("Errors: []")
      run!
    end

    it "will log the message from the containing class" do
      expect(mock_logger).to receive(:info).with("I'm running from the block")
      run!
    end

    context "when an error is thrown" do
      before do
        allow(mock_logger).to receive(:info).with("|----  Starting Strategy  ----|").and_raise(StandardError)
      end

      it "will log the error message" do
        expect(mock_logger).to receive(:error).with a_string_including("ERROR - ")
        run!
      end

      it "will log the boilerplate summary", :aggregate_failures do
        expect(mock_logger).to receive(:info).with("|---------  Summary  ---------|")
        expect(mock_logger).to receive(:info).with("Num Ticks Processed: 0")
        run!
      end
    end
  end
end