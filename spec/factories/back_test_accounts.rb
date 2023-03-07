FactoryBot.define do
  factory :back_test_account, class: "Accounts::BackTestAccount" do
    starting_balance { 5000.00 }
    current_balance { 5000.00 }
  end
end