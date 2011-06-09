require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get find" do
    get :find
    assert_response :success
  end

end
