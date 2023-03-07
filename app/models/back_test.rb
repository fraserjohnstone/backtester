class BackTest < ApplicationRecord
  include ActionView::Helpers::DateHelper
  class InvalidProgressDateError < StandardError; end

  default_scope -> { where(destroying: false) }

  scope :running, -> { where(ended_at: nil) }
  scope :complete, -> { where.not(ended_at: nil) }

  validates_presence_of :strategy_class

  belongs_to :strategy, polymorphic: true

  after_create :create_account

  STATE_READY = "state_ready"
  STATE_RUNNING = "state_running"
  STATE_MANUALLY_FINISHED = "state_manually_finished"
  STATE_ORGANICALLY_FINISHED = "state_organically_finished"
  STATE_EXCEPTION = "state_exception"

  DEFAULT_RISK_PCT = 1
  DEFAULT_COMMISSION_PCT = 3.5
  DEFAULT_SYMBOLS = ["AUDCAD", "MSFT"]
  DEFAULT_START_DATE = DateTime.parse("2018-01-01")
  DEFAULT_END_DATE = DateTime.parse("2019-01-01")
  DEFAULT_TRAIL_STOPS = true
  DEFAULT_BREAK_EVEN = false
  DEFAULT_TARGET_PROFIT_TO_LOSS_RATIO = 2
  DEFAULT_PENDING_POSITION_EXPIRY_PERIOD = 2.hours
  DEFAULT_TAKE_PROFIT = true
  DEFAULT_MAX_SPREAD = 2.0
  DEFAULT_STARTING_BALANCE = 20000.0
  DEFAULT_TICKS_PROCESSED_IN_PERIOD = []


  attribute :risk_pct, default: DEFAULT_RISK_PCT
  attribute :commission_pct, default: DEFAULT_COMMISSION_PCT
  attribute :symbols, default: DEFAULT_SYMBOLS
  attribute :start_date, default: DEFAULT_START_DATE
  attribute :end_date, default: DEFAULT_END_DATE
  attribute :ended_at, default: nil
  attribute :trail_stops, default: DEFAULT_TRAIL_STOPS
  attribute :break_even, default: DEFAULT_BREAK_EVEN
  attribute :take_profit, default: DEFAULT_TAKE_PROFIT
  attribute :destroying, default: false
  attribute :target_profit_to_loss_ratio, default: DEFAULT_TARGET_PROFIT_TO_LOSS_RATIO
  attribute :pending_position_expiry_period, default: DEFAULT_PENDING_POSITION_EXPIRY_PERIOD
  attribute :progress_date, default: DEFAULT_START_DATE
  attribute :max_spread, default: DEFAULT_MAX_SPREAD
  attribute :starting_balance, default: DEFAULT_STARTING_BALANCE
  attribute :ticks_processed_in_period, default: DEFAULT_TICKS_PROCESSED_IN_PERIOD

  FINISHED_STATES = [STATE_MANUALLY_FINISHED, STATE_ORGANICALLY_FINISHED, STATE_EXCEPTION]

  has_many :positions, dependent: :destroy
  belongs_to :back_test_account, class_name: "Accounts::BackTestAccount", dependent: :destroy, optional: true

  def run!
    update(state: STATE_RUNNING)
    strategy.run!(back_test: self)
  end

  def account
    back_test_account
  end

  def unrealised_profit_loss
    return 0.0 if positions.open.empty?

    positions.open.pluck(:gross_profit).sum
  end

  def finished?
    FINISHED_STATES.include?(state)
  end

  def running?
    !finished?
  end

  def manually_finish!
    update(ended_at: DateTime.now, state: STATE_MANUALLY_FINISHED)
  end

  def organically_finish!
    update(ended_at: DateTime.now, state: STATE_ORGANICALLY_FINISHED)
  end

  def exception_finish!
    update(ended_at: DateTime.now, state: STATE_EXCEPTION)
  end

  def created_at_readable
    day = created_at.strftime("%-d").to_i.ordinalize

    created_at.strftime("#{day} %b %Y at %T")
  end

  def return_as_pct
    return 0.0 unless back_test_account.present?
    (((account.current_balance - account.starting_balance) / account.starting_balance) * 100).round(2)
  end

  def average_return
    return 0 unless positions.closed.any?
    positions.closed.pluck(:gross_profit).sum.to_f/positions.closed.count
  end

  def average_win
    return 0 unless positions.wins.any?
    positions.wins.pluck(:gross_profit).sum.to_f/positions.wins.count
  end

  def average_loss
    return 0 unless positions.losses.any?
    positions.losses.pluck(:gross_profit).sum.to_f/positions.losses.count
  end

  def set_progress(progress_date:)
    raise InvalidProgressDateError, "Progress date is before the start date" if progress_date < start_date
    update(progress_date: progress_date)
  end

  def progress_as_pct
    return 0.0 if progress_date.nil?

    total_days = (end_date - start_date).to_f
    current_days = (progress_date - start_date).to_f

    ((current_days / total_days) * 100).round(2)
  end

  def seconds_elapsed
    DateTime.now.to_i - created_at.to_i
  end

  def life_time
    if running?
      DateTime.now.to_i - created_at.to_i
    else
      ended_at.to_i - created_at.to_i
    end
  end

  def estimated_finish_time
    return 0.0 if progress_as_pct == 0.0

    fraction_complete = (100.0/progress_as_pct)
    estimated_time_seconds = fraction_complete * seconds_elapsed
    seconds_left = estimated_time_seconds - seconds_elapsed

    created_at + seconds_left.seconds
  end

  def estimated_time_left
    return "calculating..." if progress_as_pct == 0.0
    distance_of_time_in_words(created_at, estimated_finish_time, include_minutes: true, include_seconds: true)
  end

  def pct_changes
    @pct_changes ||= positions.closed.map(&:pct_change)
  end

  def mean_pct_change
    pct_changes.mean
  end

  def std_dev_pct_changes
    pct_changes.stdev
  end

  def sharpe_ratio
    return 0.0 unless positions.closed.any?

    mean_pct_change/std_dev_pct_changes
  end

  def create_account
    Accounts::BackTestAccount.create!(back_test: self, starting_balance: starting_balance)
  end
end

