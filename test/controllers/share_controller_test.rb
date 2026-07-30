require "test_helper"

class ShareControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user_two = users(:two)
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
end
