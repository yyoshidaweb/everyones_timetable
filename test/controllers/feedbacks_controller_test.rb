require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "guest can submit feedback" do
    assert_difference("Feedback.count", 1) do
      assert_emails 1 do
        post feedbacks_path, params: { feedback: { body: "ゲストからのご意見" } }
      end
    end

    feedback = Feedback.order(:id).last
    assert_nil feedback.user
    assert_equal "ゲストからのご意見", feedback.body
    assert_redirected_to root_path
    assert_equal "ご意見を送信しました。ありがとうございます。", flash[:notice]
  end

  test "signed in user feedback is associated" do
    sign_in users(:one)

    assert_difference("Feedback.count", 1) do
      post feedbacks_path, params: { feedback: { body: "ログインユーザーからのご意見" } }
    end

    feedback = Feedback.order(:id).last
    assert_equal users(:one), feedback.user
    assert_redirected_to root_path
  end

  test "empty body is rejected" do
    assert_no_difference("Feedback.count") do
      post feedbacks_path, params: { feedback: { body: "" } }
    end

    assert_redirected_to root_path
    assert flash[:alert].present?
  end

  test "preview environment does not send email" do
    ApplicationController.stub(:preview_environment?, true) do
      assert_no_emails do
        assert_difference("Feedback.count", 1) do
          post feedbacks_path, params: { feedback: { body: "プレビューからのご意見" } }
        end
      end
    end
  end
end
