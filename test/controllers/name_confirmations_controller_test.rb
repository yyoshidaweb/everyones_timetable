require "test_helper"

class NameConfirmationsControllerTest < ActionDispatch::IntegrationTest
  # Devise のテストヘルパーをインクルード
  include Devise::Test::IntegrationHelpers

  # 各テストの前に実行されるセットアップメソッド
  setup do
    @user = users(:name_unconfirmed) # 名前が未確認のユーザーを利用
    sign_in @user # テスト用のログイン状態を再現
  end

  # モーダル表示のテスト
  test "should get new as modal" do
    get new_name_confirmation_url, headers: { "Turbo-Frame" => "modal" } # モーダルとして表示
    assert_response :success
    assert_includes response.body, "表示名を確認してください"
    assert_includes response.body, "この名前で続ける"
  end

  # モーダル以外での表示は想定していないため直接アクセスはリダイレクトされる
  test "should redirect new when not turbo frame request" do
    get new_name_confirmation_url
    assert_redirected_to root_url
  end

  # ログアウト時のモーダル表示アクションのテスト
  test "should redirect new when not logged in" do
    sign_out @user # ログアウト状態を再現
    get new_name_confirmation_url, headers: { "Turbo-Frame" => "modal" }
    assert_redirected_to root_url
  end

  # 名前を確認済みのユーザーには表示されない
  test "should redirect new when name is already confirmed" do
    sign_out @user
    sign_in users(:one) # 名前を確認済みのユーザーでログイン
    get new_name_confirmation_url, headers: { "Turbo-Frame" => "modal" }
    assert_redirected_to root_url
  end

  # フォームに入力されている名前で更新される
  test "should update name with submitted value" do
    patch name_confirmation_url,
      params: { user: { name: "変更後の名前" } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    @user.reload
    assert_equal "変更後の名前", @user.name
    assert @user.name_confirmed? # 名前は確認済みになる
  end

  # 名前を変更しなかった場合も確認済みになる
  test "should confirm name when name is not modified" do
    patch name_confirmation_url,
      params: { user: { name: @user.name } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    @user.reload
    assert_equal "Name Unconfirmed", @user.name
    assert @user.name_confirmed?
  end

  # 確認後にモーダルが閉じる
  test "turbo_stream: modal is closed after confirmation" do
    patch name_confirmation_url,
      params: { user: { name: "変更後の名前" } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    # モーダルを閉じる Turbo Stream が返っているか
    assert_includes response.body, 'turbo-stream action="replace" target="modal"'
    # 再度読み込まれないよう src が取り除かれているか
    assert_not_includes response.body, new_name_confirmation_path
  end

  # 名前が空の場合は確認済みにならない
  test "should not confirm when name is blank" do
    patch name_confirmation_url,
      params: { user: { name: "" } },
      headers: { "Turbo-Frame" => "modal" }
    @user.reload
    assert_equal "Name Unconfirmed", @user.name # 名前は変更されない
    assert_not @user.name_confirmed? # 名前は未確認のまま
    # HTTPステータスが422（バリデーションエラー）であることを確認
    assert_response :unprocessable_entity
  end

  # ログアウト時の更新アクションのテスト
  test "should redirect update when not logged in" do
    sign_out @user # ログアウト状態を再現
    patch name_confirmation_url, params: { user: { name: "Hacker" } }
    assert_redirected_to root_url
    assert_not @user.reload.name_confirmed? # 未ログインは更新不可
  end
end
