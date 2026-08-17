require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get terms" do
    get terms_path
    assert_response :success
  end

  test "should get privacy" do
    get privacy_path
    assert_response :success
  end

  test "footer includes status page link" do
    get terms_path
    assert_response :success
    assert_select "a[href=?][target=_blank][rel='noopener noreferrer']",
                  "https://stats.uptimerobot.com/ZRof25OUD7",
                  text: "稼働状況"
  end
end
