require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  # Devise のテストヘルパーをインクルード
  include Devise::Test::IntegrationHelpers

  # トップページ表示
  test "should get index" do
    get "/"
    assert_response :success
  end

  # ログイン時のみご意見箱（Googleフォーム埋め込み）がある
  test "index includes embedded feedback google form when signed in" do
    sign_in users(:one)
    get "/"
    assert_select "iframe[title=?]", "ご意見箱"
    assert_select "iframe[src=?]",
                  "https://docs.google.com/forms/d/e/1FAIpQLSdDYkoTm6JJ40NbK2gK2p-9p626HNShJdPssRoj1sG8KkKV_g/viewform?embedded=true"
  end

  # 未ログイン時はご意見箱を表示しない
  test "index does not include feedback google form when guest" do
    get "/"
    assert_select "iframe[title=?]", "ご意見箱", count: 0
  end

  # トップページにcanonicalタグが付与される
  test "index includes canonical url" do
    get "/"
    assert_select "link[rel=canonical][href=?]", "http://www.example.com/"
  end

  # html要素にlang="ja"が設定される
  test "index includes html lang ja" do
    get "/"
    assert_select "html[lang=ja]"
  end

  # トップページにサイト名とサイトリンク対象ページの構造化データがある
  test "index includes website structured data with sitelinks" do
    get "/"
    assert_select "script[type='application/ld+json']" do |elements|
      data = JSON.parse(elements.first.text)
      website = data["@graph"].find { |node| node["@type"] == "WebSite" }
      sitelinks = data["@graph"].find { |node| node["@type"] == "ItemList" }

      assert_equal "みんなのタイムテーブル", website["name"]
      assert_equal "http://www.example.com/", website["url"]
      assert_equal(
        [ "みんなが作ったタイムテーブル", "利用規約", "プライバシーポリシー" ],
        sitelinks["itemListElement"].map { |item| item["name"] }
      )
      assert_equal(
        [
          "http://www.example.com/events",
          "http://www.example.com/terms",
          "http://www.example.com/privacy"
        ],
        sitelinks["itemListElement"].map { |item| item["url"] }
      )
    end
  end

  # フッターの主要ページ案内はサイトリンク対象の3ページに限定する
  test "footer includes only sitelink pages in primary nav" do
    get "/"
    assert_select "footer nav[aria-label=主要ページ]" do
      assert_select "a", count: 3
      assert_select "a[href=?]", events_path, text: "みんなが作ったタイムテーブル"
      assert_select "a[href=?]", terms_path, text: "利用規約"
      assert_select "a[href=?]", privacy_path, text: "プライバシーポリシー"
    end
  end

  # 名前が未確認のユーザーには名前変更モーダルが自動で読み込まれる
  test "should load name confirmation modal when name is not confirmed" do
    sign_in users(:name_unconfirmed)
    get "/"
    assert_includes response.body, new_name_confirmation_path
  end

  # 名前を確認済みのユーザーには名前変更モーダルが読み込まれない
  test "should not load name confirmation modal when name is confirmed" do
    sign_in users(:one)
    get "/"
    assert_not_includes response.body, new_name_confirmation_path
  end
end
