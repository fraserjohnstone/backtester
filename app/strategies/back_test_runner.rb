class BackTestRunner < ApplicationJob
  def perform(**kwargs)
    BackTest.find(kwargs[:back_test_id]).run!
  end
end