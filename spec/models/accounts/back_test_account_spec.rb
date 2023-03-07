require "rails_helper"

describe Accounts::BackTestAccount do
  let(:instance) { described_class.new }

  describe "defaults" do
    describe "starting_balance" do
      subject { instance.starting_balance }
      it { is_expected.to eq Accounts::BackTestAccount::DEFAULT_STARTING_BALANCE }
    end

    describe "current_balance" do
      subject { instance.current_balance }
      it { is_expected.to eq Accounts::BackTestAccount::DEFAULT_STARTING_BALANCE }
    end
  end

  describe "overriding defaults" do
    let(:instance) { described_class.new(starting_balance: starting_balance) }

    let(:starting_balance) { 10000.00 }

    it "will set the starting balance" do
      expect(instance.starting_balance).to eq starting_balance
    end

    it "will set the current balance" do
      expect(instance.current_balance).to eq starting_balance
    end
  end
end