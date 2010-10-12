require 'test_helper'

class WaitlistEntriesControllerTest < ActionController::TestCase
  setup do
    @waitlist_entry = waitlist_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:waitlist_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create waitlist_entry" do
    assert_difference('WaitlistEntry.count') do
      post :create, :waitlist_entry => @waitlist_entry.attributes
    end

    assert_redirected_to waitlist_entry_path(assigns(:waitlist_entry))
  end

  test "should show waitlist_entry" do
    get :show, :id => @waitlist_entry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @waitlist_entry.to_param
    assert_response :success
  end

  test "should update waitlist_entry" do
    put :update, :id => @waitlist_entry.to_param, :waitlist_entry => @waitlist_entry.attributes
    assert_redirected_to waitlist_entry_path(assigns(:waitlist_entry))
  end

  test "should destroy waitlist_entry" do
    assert_difference('WaitlistEntry.count', -1) do
      delete :destroy, :id => @waitlist_entry.to_param
    end

    assert_redirected_to waitlist_entries_path
  end
end
