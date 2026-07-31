require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  # Devise のテストヘルパーをインクルード
  include Devise::Test::IntegrationHelpers

  # トップページ表示
  test "should get index" do
    get "/"
    assert_response :success
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
