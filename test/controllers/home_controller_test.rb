require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  # Devise のテストヘルパーをインクルード
  include Devise::Test::IntegrationHelpers

  # トップページ表示
  test "should get index" do
    get "/"
    assert_response :success
  end

  # トップページにご意見箱（Googleフォーム埋め込み）がある
  test "index includes embedded feedback google form" do
    get "/"
    assert_select "iframe[title=?]", "みんなのタイムテーブル ご意見箱"
    assert_select "iframe[src=?]",
                  "https://docs.google.com/forms/d/e/1FAIpQLSdDYkoTm6JJ40NbK2gK2p-9p626HNShJdPssRoj1sG8KkKV_g/viewform?embedded=true"
  end

  # トップページにcanonicalタグが付与される
  test "index includes canonical url" do
    get "/"
    assert_select "link[rel=canonical][href=?]", "http://www.example.com/"
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
