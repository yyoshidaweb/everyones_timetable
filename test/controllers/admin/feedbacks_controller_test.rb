require "test_helper"

class Admin::FeedbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @developer = users(:developer)
    @free_user = users(:one)
  end

  test "developer can access feedbacks index" do
    sign_in @developer
    get admin_feedbacks_url
    assert_response :success
    assert_match feedbacks(:one).body, response.body
    assert_match feedbacks(:guest_feedback).body, response.body
    assert_match "未ログイン", response.body
  end

  test "free user cannot access feedbacks index" do
    sign_in @free_user
    get admin_feedbacks_url
    assert_response :not_found
  end

  test "guest cannot access feedbacks index" do
    get admin_feedbacks_url
    assert_redirected_to root_url
  end

  test "admin dashboard links to feedbacks" do
    sign_in @developer
    get admin_dashboard_url
    assert_response :success
    assert_select "a[href=?]", admin_feedbacks_path, text: "ご意見箱"
  end
end
