require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_path
    assert_response :success
  end

  # ログインページは検索対象外
  test "new session includes noindex robots meta" do
    get new_session_path
    assert_response :success
    assert_select "meta[name=robots][content='noindex, nofollow']"
  end
end
