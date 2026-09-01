require "test_helper"

# 検索の入り口はタイムテーブルのみ。子タブは canonical で集約し、対象外ページは noindex にする
class SearchIndexingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @event = events(:one)
    @empty_event = events(:no_performance_event)
    @timetable_url = "http://www.example.com/t/#{@event.event_key}"
  end

  # ===== canonical で /t/:event_key に集約（noindex しない） =====

  test "event overview canonicalizes to timetable without noindex" do
    get event_path(@event.event_key)
    assert_canonicalized_to_timetable
  end

  test "performers index canonicalizes to timetable without noindex" do
    get event_performers_path(@event.event_key)
    assert_canonicalized_to_timetable
  end

  test "performer show canonicalizes to timetable without noindex" do
    get event_performer_path(@event.event_key, performers(:one))
    assert_canonicalized_to_timetable
  end

  test "stages index canonicalizes to timetable without noindex" do
    get event_stages_path(@event.event_key)
    assert_canonicalized_to_timetable
  end

  test "stage show canonicalizes to timetable without noindex" do
    get event_stage_path(@event.event_key, stages(:one))
    assert_canonicalized_to_timetable
  end

  # ===== noindex =====

  test "my timetable includes noindex" do
    get show_my_timetable_path(event_key: @event.event_key, username: @user.username)
    assert_noindex
  end

  test "login page includes noindex" do
    get new_session_path
    assert_noindex
  end

  test "share page includes noindex" do
    get share_path(type: "event", event_key: @event.event_key)
    assert_noindex
  end

  test "event new page includes noindex" do
    sign_in @user
    get new_event_path
    assert_noindex
  end

  test "event edit page includes noindex" do
    sign_in @user
    get edit_event_path(@event.event_key)
    assert_noindex
  end

  test "timetable without performances includes noindex" do
    get show_timetable_path(@empty_event.event_key)
    assert_noindex
  end

  test "event overview without performances includes noindex" do
    get event_path(@empty_event.event_key)
    assert_noindex
    assert_not_canonicalized_to_timetable(@empty_event)
  end

  test "unlisted event includes noindex" do
    get event_path(events(:unlisted).event_key)
    assert_noindex
  end

  test "performers index without performances includes noindex" do
    get event_performers_path(@empty_event.event_key)
    assert_noindex
    assert_not_canonicalized_to_timetable(@empty_event)
  end

  test "stages index without performances includes noindex" do
    get event_stages_path(@empty_event.event_key)
    assert_noindex
    assert_not_canonicalized_to_timetable(@empty_event)
  end

  # ===== サイトマップ =====

  test "sitemap includes only timetables with performances" do
    get sitemap_path
    assert_includes response.body, "<loc>#{@timetable_url}</loc>"
    assert_not_includes response.body, "<loc>http://www.example.com/events/#{@event.event_key}</loc>"
    assert_not_includes response.body, "<loc>http://www.example.com/t/#{@empty_event.event_key}</loc>"
  end

  private
    def assert_canonicalized_to_timetable
      assert_response :success
      assert_select "link[rel=canonical][href=?]", @timetable_url
      assert_select "meta[name=robots][content='noindex, nofollow']", count: 0
    end

    def assert_noindex
      assert_response :success
      assert_select "meta[name=robots][content='noindex, nofollow']"
    end

    def assert_not_canonicalized_to_timetable(event)
      assert_select "link[rel=canonical][href=?]", "http://www.example.com/t/#{event.event_key}", count: 0
    end
end
