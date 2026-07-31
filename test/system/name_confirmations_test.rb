require "application_system_test_case"

class NameConfirmationsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
    @user = users(:name_unconfirmed)
    login_as @user, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "名前を確定するとモーダルが閉じて再表示されない" do
    visit root_path
    assert_text "表示名を確認してください"

    fill_in "名前", with: "新しい名前"
    click_on "この名前で続ける"

    assert_no_text "表示名を確認してください"
    assert_equal "新しい名前", @user.reload.name
    assert @user.name_confirmed?

    # ページを遷移しても再表示されない
    visit root_path
    assert_no_text "表示名を確認してください"
  end

  test "確定後にブラウザバックしても再表示されない" do
    visit root_path
    assert_text "表示名を確認してください"

    click_on "この名前で続ける"
    assert_no_text "表示名を確認してください"

    # 別ページへ遷移してから戻る
    click_on "利用規約"
    assert_current_path terms_path
    page.go_back

    assert_current_path root_path
    assert_no_text "表示名を確認してください"
  end
end
