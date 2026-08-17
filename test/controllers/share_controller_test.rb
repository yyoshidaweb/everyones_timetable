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

  test "should show favorite marker checkbox for signed-in event share" do
    sign_in @user
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

  test "should hide favorite marker checkbox for guest event share" do
    get share_path(type: "event", event_key: @event.event_key),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :success
    assert_select "input[data-timetable-image-target='favoriteMarkers'][type='checkbox']", count: 0
  end

  # 共有ページ本体は検索対象外（モーダル用URLがクロールされるため）
  test "event share page includes noindex robots meta" do
    get share_path(type: "event", event_key: @event.event_key)
    assert_response :success
    assert_select "meta[name=robots][content='noindex, nofollow']"
  end

  test "should render long-press message and desktop-only download button in preview" do
    get share_path(type: "event", event_key: @event.event_key),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :success
    assert_select "button[data-action='click->timetable-image#download'][class*='min-[1025px]:flex']", count: 1
    assert_select "p", text: "画像を長押しして保存してください。"
    assert_select "img[data-timetable-image-target='previewImage'][class*='max-h-[50svh]']"
    assert_select "div.overflow-auto img[data-timetable-image-target='previewImage']", count: 0
    assert_select "button[data-action='click->timetable-image#backToShare']", text: "←戻る", count: 2
    assert_select "[data-action='click->modal#stop']" do |elements|
      classes = elements.first["class"]
      assert_includes classes, "min-h-0"
      assert_includes classes, "overflow-y-auto"
      refute_includes classes, "justify-center"
    end
  end

  test "should show image save button for published my timetable share" do
    get share_path(type: "my-timetable", event_key: @event.event_key, username: @user.username),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :success
    assert_select "button[data-action='click->timetable-image#start']", text: /画像を保存/
    assert_select "input[data-timetable-image-target='favoriteMarkers'][type='checkbox']", count: 0
  end
end
