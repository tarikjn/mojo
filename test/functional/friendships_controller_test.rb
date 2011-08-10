require 'test_helper'

class FriendshipsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get approve" do
    get :approve
    assert_response :success
  end

  test "should get ignore" do
    get :ignore
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

end
