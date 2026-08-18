require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "terms page does not include website structured data" do
    get terms_path
    assert_response :success
    assert_select "script[type='application/ld+json']", count: 0
  end

  test "should get privacy" do
    get privacy_path
    assert_response :success
  end

  test "footer primary nav includes sitelink pages" do
    get terms_path
    assert_response :success
    assert_select "footer nav[aria-label=主要ページ]" do
      assert_select "a[href=?]", events_path, text: "みんなが作ったタイムテーブル"
      assert_select "a[href=?]", terms_path, text: "利用規約"
      assert_select "a[href=?]", privacy_path, text: "プライバシーポリシー"
    end
  end

  test "footer includes status page link" do
    get terms_path
    assert_response :success
    assert_select "a[href=?][target=_blank][rel='noopener noreferrer']",
                  "https://stats.uptimerobot.com/ZRof25OUD7",
                  text: "稼働状況"
  end
end
