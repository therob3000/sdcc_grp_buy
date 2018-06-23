require 'test_helper'

class LineDaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_day = line_days(:one)
  end

  test "should get index" do
    get line_days_url
    assert_response :success
  end

  test "should get new" do
    get new_line_day_url
    assert_response :success
  end

  test "should create line_day" do
    assert_difference('LineDay.count') do
      post line_days_url, params: { line_day: { day: @line_day.day, description: @line_day.description } }
    end

    assert_redirected_to line_day_url(LineDay.last)
  end

  test "should show line_day" do
    get line_day_url(@line_day)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_day_url(@line_day)
    assert_response :success
  end

  test "should update line_day" do
    patch line_day_url(@line_day), params: { line_day: { day: @line_day.day, description: @line_day.description } }
    assert_redirected_to line_day_url(@line_day)
  end

  test "should destroy line_day" do
    assert_difference('LineDay.count', -1) do
      delete line_day_url(@line_day)
    end

    assert_redirected_to line_days_url
  end
end
