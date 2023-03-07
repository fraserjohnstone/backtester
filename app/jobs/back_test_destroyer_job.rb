class BackTestDestroyerJob < ApplicationJob
  def perform(**kwargs)
    back_test = BackTest.find(kwargs[:back_test_id])

    back_test.destroy
  end
end