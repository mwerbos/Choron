require 'test_helper'

class BidsControllerTest < ActionController::TestCase
  setup do
    @bid = bids(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bids)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bid" do
    assert_difference('Bid.count') do
      post :create, :bid => { :amount => @bid.amount }
    end

    assert_redirected_to bid_path(assigns(:bid))
  end

  test "should show bid" do
    get :show, :id => @bid
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @bid
    assert_response :success
  end

  test "should update bid" do
    put :update, :id => @bid, :bid => { :amount => @bid.amount }
    assert_redirected_to bid_path(assigns(:bid))
  end

  test "should destroy bid" do
    assert_difference('Bid.count', -1) do
      delete :destroy, :id => @bid
    end

    assert_redirected_to bids_path
  end
end
