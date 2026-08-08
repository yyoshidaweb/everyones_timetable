require "test_helper"

class MyTimetablesControllerTest < ActionDispatch::IntegrationTest
  # Devise のテストヘルパーをインクルード
  include Devise::Test::IntegrationHelpers

  setup do
    # Google 認証のテスト用ユーザーを作成
    @user = users(:one)
    @user_two = users(:two)
    # テスト用のログイン状態を再現
    sign_in @user
    @event = events(:one)
    @no_performance_event = events(:no_performance_event)
    @day1 = days(:one)
    @day2 = days(:two)
    @performance1 = performances(:one)
    @performance2 = performances(:two)
    @performance3 = performances(:three)
    @performance4 = performances(:four)
  end

  # 未ログインでもタイムテーブルページにアクセス可能
  test "should get my_timetable with logout" do
    sign_out @user
    get show_my_timetable_path(event_key: @event.event_key, username: @user.username)
    assert_response :success
  end

  # ログイン状態でタイムテーブルページにアクセス可能
  test "should show my_timetable with login" do
    get show_my_timetable_path(event_key: @event.event_key, username: @user.username)
    assert_response :success
  end

  # マイタイムテーブルは検索エンジンにインデックスさせない
  test "my timetable includes noindex robots meta" do
    get show_my_timetable_path(event_key: @event.event_key, username: @user.username)
    assert_response :success
    assert_select "meta[name=robots][content='noindex, nofollow']"
  end

  test "should not get unpublished my_timetable with logout" do
    sign_out @user
    unpublished_event = events(:unpublished)
    get show_my_timetable_path(event_key: unpublished_event.event_key, username: @user.username)
    assert_response :not_found
  end

  test "should not get unpublished my_timetable by other user" do
    sign_out @user
    sign_in @user_two
    unpublished_event = events(:unpublished)
    get show_my_timetable_path(event_key: unpublished_event.event_key, username: @user.username)
    assert_response :not_found
  end
end
