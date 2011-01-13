require 'test_helper'

class StepflowControllerTest < ActionController::TestCase
  test "should get discover" do
    get :discover
    assert_response :success
  end

end
