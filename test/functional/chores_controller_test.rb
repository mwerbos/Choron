require 'test_helper'

class ChoresControllerTest < ActionController::TestCase
  setup do
    @chore = chores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chore" do
    assert_difference('Chore.count') do
      post :create, :chore => { :due_date => @chore.due_date, :name => @chore.name }
    end

    assert_redirected_to chore_path(assigns(:chore))
  end

  test "should show chore" do
    get :show, :id => @chore
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @chore
    assert_response :success
  end

  test "should update chore" do
    put :update, :id => @chore, :chore => { :due_date => @chore.due_date, :name => @chore.name }
    assert_redirected_to chore_path(assigns(:chore))
  end

  test "should destroy chore" do
    assert_difference('Chore.count', -1) do
      delete :destroy, :id => @chore
    end

    assert_redirected_to chores_path
  end
end
