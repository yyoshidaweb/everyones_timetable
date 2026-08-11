require "test_helper"

class ShareControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user_two = users(:two)
    @event = events(:one)
    @unpublished_event = events(:unpublished)
  end

  test "should return 404 for unpublished event share with logout" do
    get share_path(type: "event", event_key: @unpublished_event.event_key)
    assert_response :not_found
  end

  test "should return 404 for unpublished event share by other user" do
    sign_in @user_two
    get share_path(type: "event", event_key: @unpublished_event.event_key)
    assert_response :not_found
  end

  test "should return 404 for unpublished my timetable share with logout" do
    get share_path(type: "my-timetable", event_key: @unpublished_event.event_key, username: @user.username)
    assert_response :not_found
  end

  test "should show image save button and day select for published event share" do
    get share_path(type: "event", event_key: @event.event_key),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :success
    assert_select "button[data-action='click->timetable-image#start']", text: /画像を保存/
    assert_select "[data-timetable-image-capture-url-value]"
    assert_select "[data-timetable-image-days-value]"
    assert_select "select[data-timetable-image-target='daySelect']"
    assert_select "select[data-timetable-image-target='daySelect'] option", minimum: 1
    assert_select "input[data-timetable-image-target='favoriteMarkers'][type='checkbox']"
  end

  test "should show image save button for published my timetable share" do
    get share_path(type: "my-timetable", event_key: @event.event_key, username: @user.username),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :success
    assert_select "button[data-action='click->timetable-image#start']", text: /画像を保存/
  end
end
