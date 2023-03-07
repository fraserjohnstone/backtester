require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :back_tests, only: [:index, :new, :create, :edit]
  patch :clone_back_test, to: "back_tests#clone"

  resources :positions, only: [:index, :show]
  resources :strategies, only: [:index, :new, :create, :edit, :update]
  get :destroy_strategy, to: "strategies#destroy"

  get :positions_list_item_data, to: "positions#positions_list_item_data"
  get :price_history_for_position, to: "positions#price_history_for_position"

  get :run_back_test, to: "back_tests#run"

  get :destroy_back_test, to: "back_tests#destroy_back_test"
  get :stop_back_test, to: "back_tests#stop_back_test"
  get :back_tests_list_item_data, to: "back_tests#back_tests_list_item_data"
  get :profit_loss_series_for_back_test, to: "back_tests#profit_loss_series_for_back_test"
  get :profit_loss_bars_for_back_test, to: "back_tests#profit_loss_bars_for_back_test"
end