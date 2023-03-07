module Accounts
  class BackTestAccount < ApplicationRecord
    class InvalidBalanceError < StandardError; end

    DEFAULT_STARTING_BALANCE = 5000.0

    attribute :starting_balance, default: DEFAULT_STARTING_BALANCE

    after_initialize :set_current_balance

    has_one :back_test, inverse_of: :back_test_account

    def current_balance(net: false)
      if net
        starting_balance + back_test.positions.closed.map(&:net_profit).sum
      else
        starting_balance + back_test.positions.closed.pluck(:gross_profit).sum
      end
    end

    private

    def set_current_balance
      self.current_balance = starting_balance unless self.current_balance
    end
  end
end