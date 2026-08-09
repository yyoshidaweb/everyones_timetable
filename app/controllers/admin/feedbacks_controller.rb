class Admin::FeedbacksController < Admin::BaseController
  def index
    @page_title = "ご意見箱"
    @feedbacks_count = Feedback.count
    @feedbacks = Feedback.includes(:user).order(created_at: :desc)
  end
end
