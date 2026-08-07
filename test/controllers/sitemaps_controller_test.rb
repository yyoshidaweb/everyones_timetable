require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "should get sitemap as xml" do
    get sitemap_path
    assert_response :success
    assert_equal "application/xml", response.media_type
  end

  # 静的ページがサイトマップに含まれる
  test "sitemap includes static pages" do
    get sitemap_path
    [ "http://www.example.com", "http://www.example.com/events", "http://www.example.com/terms", "http://www.example.com/privacy" ].each do |url|
      assert_includes response.body, "<loc>#{url}</loc>"
    end
  end

  # 公開イベントのイベントページとタイムテーブルページがサイトマップに含まれる
  test "sitemap includes published events" do
    get sitemap_path
    event = events(:one)
    assert_includes response.body, "<loc>http://www.example.com/events/#{event.event_key}</loc>"
    assert_includes response.body, "<loc>http://www.example.com/t/#{event.event_key}</loc>"
  end

  # 非公開イベントはサイトマップに含まれない
  test "sitemap excludes unpublished events" do
    get sitemap_path
    event = events(:unpublished)
    assert_not_includes response.body, "<loc>http://www.example.com/events/#{event.event_key}</loc>"
    assert_not_includes response.body, "<loc>http://www.example.com/t/#{event.event_key}</loc>"
  end

  # マイタイムテーブルは重複コンテンツになるためサイトマップに含めない
  test "sitemap excludes my timetables" do
    get sitemap_path
    assert_not_includes response.body, "<loc>http://www.example.com/t/#{events(:one).event_key}/"
  end
end
