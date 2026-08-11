require "test_helper"

class TimetableImagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @event = events(:one)
    @unpublished_event = events(:unpublished)
    @day = days(:one)
  end

  test "should return capture html for published event" do
    get timetable_image_capture_path(type: "event", event_key: @event.event_key, d: @day.date)
    assert_response :success
    assert_select "[data-timetable-image-capture-root]"
    assert_match "powered by みんなのタイムテーブル", response.body
  end

  test "should return capture html for published my timetable" do
    get timetable_image_capture_path(
      type: "my-timetable",
      event_key: @event.event_key,
      username: @user.username,
      d: @day.date
    )
    assert_response :success
    assert_select "[data-timetable-image-capture-root]"
  end

  test "should return 404 for unpublished event capture" do
    get timetable_image_capture_path(type: "event", event_key: @unpublished_event.event_key, d: Date.current)
    assert_response :not_found
  end

  test "should return 404 for invalid date" do
    get timetable_image_capture_path(type: "event", event_key: @event.event_key, d: "1999-01-01")
    assert_response :not_found
  end
end
