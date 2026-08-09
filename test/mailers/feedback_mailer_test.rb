require "test_helper"

class FeedbackMailerTest < ActionMailer::TestCase
  test "submitted" do
    feedback = feedbacks(:one)
    email = FeedbackMailer.submitted(feedback)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "developer@example.com" ], email.to
    assert_equal "【みんなのタイムテーブル】ご意見箱に投稿がありました", email.subject
    assert_includes email.text_part.body.to_s, feedback.body
    assert_includes email.html_part.body.to_s, feedback.body
  end
end
