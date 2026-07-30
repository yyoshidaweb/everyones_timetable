require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @developer = users(:developer)
    @free_user = users(:one)
  end

  test "developer can access admin dashboard" do
    sign_in @developer
    get admin_dashboard_url
    assert_response :success
    assert_select "h2", text: "ユーザー"
    assert_select "h2", text: "タイムテーブル"
    assert_match @free_user.email, response.body
    assert_match @free_user.name, response.body
    assert_match events(:unpublished).display_name, response.body
    assert_match "非公開", response.body
  end

  test "free user cannot access admin dashboard" do
    sign_in @free_user
    get admin_dashboard_url
    assert_response :not_found
  end

  test "guest cannot access admin dashboard" do
    get admin_dashboard_url
    assert_redirected_to root_url
  end

  test "admin footer link is visible only for developer" do
    sign_in @developer
    get root_url
    assert_select "a[href=?]", admin_dashboard_path, text: "管理画面（開発者向け）"

    sign_out @developer
    sign_in @free_user
    get root_url
    assert_select "a[href=?]", admin_dashboard_path, text: "管理画面（開発者向け）", count: 0

    sign_out @free_user
    get root_url
    assert_select "a[href=?]", admin_dashboard_path, text: "管理画面（開発者向け）", count: 0
  end
end
