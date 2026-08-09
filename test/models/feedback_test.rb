require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "body is required" do
    feedback = Feedback.new(body: "")
    assert_not feedback.valid?
    assert_includes feedback.errors[:body], "を入力してください"
  end

  test "body maximum length is 2000" do
    feedback = Feedback.new(body: "a" * 2001)
    assert_not feedback.valid?
    assert feedback.errors[:body].any?
  end

  test "user is optional" do
    feedback = Feedback.new(body: "匿名のご意見")
    assert feedback.valid?
  end
end
