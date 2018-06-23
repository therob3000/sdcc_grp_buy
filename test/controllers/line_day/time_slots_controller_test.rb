require 'test_helper'

class LineDay::TimeSlotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_day_time_slot = line_day_time_slots(:one)
  end

  test "should get index" do
    get line_day_time_slots_url
    assert_response :success
  end

  test "should get new" do
    get new_line_day_time_slot_url
    assert_response :success
  end

  test "should create line_day_time_slot" do
    assert_difference('LineDay::TimeSlot.count') do
      post line_day_time_slots_url, params: { line_day_time_slot: { day: @line_day_time_slot.day, description: @line_day_time_slot.description, time: @line_day_time_slot.time } }
    end

    assert_redirected_to line_day_time_slot_url(LineDay::TimeSlot.last)
  end

  test "should show line_day_time_slot" do
    get line_day_time_slot_url(@line_day_time_slot)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_day_time_slot_url(@line_day_time_slot)
    assert_response :success
  end

  test "should update line_day_time_slot" do
    patch line_day_time_slot_url(@line_day_time_slot), params: { line_day_time_slot: { day: @line_day_time_slot.day, description: @line_day_time_slot.description, time: @line_day_time_slot.time } }
    assert_redirected_to line_day_time_slot_url(@line_day_time_slot)
  end

  test "should destroy line_day_time_slot" do
    assert_difference('LineDay::TimeSlot.count', -1) do
      delete line_day_time_slot_url(@line_day_time_slot)
    end

    assert_redirected_to line_day_time_slots_url
  end
end
